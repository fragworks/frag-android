import
  events,
  hashes,
  os,
  tables

import
  bgfxdotnim,
  sdl2 as sdl

import
  frag,
  frag/config,
  frag/logger,
  frag/graphics/camera,
  frag/graphics/two_d/spritebatch,
  frag/graphics/two_d/texture,
  frag/graphics/types,
  frag/modules/assets,
  frag/sound/sound

type
  App = ref object
    batch: SpriteBatch
    camera: Camera
    assetIds: Table[string, Hash]

var assetsLoaded = false
var originalWidth, originalHeight: float

proc resize*(e: EventArgs) =
  let event = SDLEventMessage(e).event
  let sdlEventData = event.sdlEventData
  let app = cast[App](event.userData)
  app.camera.updateViewport(sdlEventData.window.data1.float, sdlEventData.window.data2.float)

proc initApp(app: App, ctx: Frag) =
  log "Initializing app..."
  ctx.events.on(SDLEventType.WindowResize, resize)

  app.assetIds = initTable[string, Hash]()

  let filename = "textures/test01.png"
  let filename2 = "textures/test02.png"

  logDebug "Loading assets..."
  app.assetIds.add(filename, ctx.assets.load(filename, AssetType.Texture))
  app.assetIds.add(filename2, ctx.assets.load(filename2, AssetType.Texture))
  app.assetIds.add("sounds/test.ogg", ctx.assets.load("sounds/test.ogg", AssetType.Sound))

  app.batch = SpriteBatch(
    blendSrcFunc: BlendFunc.SrcAlpha,
    blendDstFunc: BlendFunc.InvSrcAlpha,
    blendingEnabled: true
  )
  app.batch.init(1000, 0)

  let size = ctx.graphics.getSize()
  originalWidth = size.x.float
  originalHeight = size.y.float


  app.camera = Camera()
  app.camera.init(0)
  app.camera.ortho(1.0, size.x.float, size.y.float)

  while not assetsLoaded and not assets.update(ctx.assets):
    continue
  assetsLoaded = true

  var sound = assets.get[Sound](ctx.assets, app.assetIds["sounds/test.ogg"])
  sound.setGain(0.5)

  sound.play()

  log "App initialized."

proc updateApp(app:App, ctx: Frag, deltaTime: float) =
  app.camera.update()
  app.batch.setProjectionMatrix(app.camera.combined)

proc renderApp(app: App, ctx: Frag, deltaTime: float64) =
  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

  if assetsLoaded:
    let tex = assets.get[Texture](ctx.assets, app.assetIds["textures/test01.png"])
    let tex2 = assets.get[Texture](ctx.assets, app.assetIds["textures/test02.png"])

    let size = ctx.graphics.getSize()
    let HALF_WIDTH = originalWidth / 2
    let HALF_HEIGHT = originalHeight / 2
    let texHalfW = tex.data.w / 2
    let texHalfH = tex.data.h / 2


    app.batch.begin()
    app.batch.draw(tex, HALF_WIDTH - texHalfW, HALF_HEIGHT - texHalfH, float tex.data.w, float tex.data.h)
    app.batch.draw(tex2, HALF_WIDTH + texHalfW, HALF_HEIGHT - texHalfH, float tex.data.w, float tex.data.h)
    app.batch.`end`()

proc shutdownApp(app: App, ctx: Frag) =
  log "Shutting down app..."
  log "App shut down."


{.emit: """
#include <SDL_main.h>

extern int cmdCount;
extern char** cmdLine;
extern char** gEnv;

N_CDECL(void, NimMain)(void);

int main(int argc, char** args) {
    cmdLine = args;
    cmdCount = argc;
    gEnv = NULL;
    NimMain();
    return nim_program_result;
}
""".}

startFrag(App(), Config(
  rootWindowTitle: "Frag Example 00-hello-world",
  resetFlags: ResetFlag.None,
  debugMode: BGFX_DEBUG_NONE
))
