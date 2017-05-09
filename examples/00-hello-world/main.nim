import
  events,
  hashes,
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
  frag/graphics/types

type
  App = ref object
    batch: SpriteBatch
    camera: Camera
    assetIds: Table[string, Hash]

var assetsLoaded = false

proc resize*(e: EventArgs) =
  let event = SDLEventMessage(e).event
  let sdlEventData = event.sdlEventData
  let app = cast[App](event.userData)
  app.camera.updateViewport(sdlEventData.window.data1.float, sdlEventData.window.data2.float)

proc initApp(app: App, ctx: Frag) =
  log "Initializing app..."
  ctx.events.on(SDLEventType.WindowResize, resize)

  let size = ctx.graphics.getSize()

  app.camera = Camera()
  app.camera.init(0)
  app.camera.ortho(1.0, size.x.float, size.y.float)
  log "App initialized."

proc updateApp(app:App, ctx: Frag, deltaTime: float) =
  discard

proc renderApp(app: App, ctx: Frag, deltaTime: float64) =
  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

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
