"""Generate a simple NEXUS pre-lobby blockout inside Unreal Editor.

Run from Unreal Editor's Python console or execute as an editor Python script.
This creates Content/Maps/L_NEXUS_PreLobby.umap with a floor, perimeter walls,
a few cover blocks, a PlayerStart, and the NEXUS game mode when available.
"""
import unreal

MAP_DIR = "/Game/Maps"
MAP_NAME = "L_NEXUS_PreLobby"
MAP_PATH = MAP_DIR + "/" + MAP_NAME

asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
editor_asset_lib = unreal.EditorAssetLibrary

if editor_asset_lib.does_asset_exist(MAP_PATH):
    unreal.log_warning("NEXUS pre-lobby map already exists; opening it.")
    unreal.EditorLoadingAndSavingUtils.open_map(MAP_PATH)
    world = unreal.EditorLevelLibrary.get_editor_world()
else:
    world = unreal.EditorLevelLibrary.new_level(MAP_PATH)

if not world:
    raise RuntimeError("Could not create or load " + MAP_PATH)

def spawn_cube(name, location, scale, material=None):
    actor = unreal.EditorLevelLibrary.spawn_actor_from_class(
        unreal.StaticMeshActor, unreal.Vector(*location), unreal.Rotator(0, 0, 0)
    )
    actor.set_actor_label(name)
    mesh_component = actor.static_mesh_component
    cube = unreal.load_object(None, "/Engine/BasicShapes/Cube.Cube")
    if cube:
        mesh_component.set_static_mesh(cube)
    actor.set_actor_scale3d(unreal.Vector(*scale))
    if material:
        mesh_component.set_material(0, material)
    return actor

# Unreal basic cube is 100 cm per side.
spawn_cube("NEXUS_Floor", (0, 0, -50), (30, 30, 1))
spawn_cube("NEXUS_Wall_North", (0, 1500, 250), (30, 1, 6))
spawn_cube("NEXUS_Wall_South", (0, -1500, 250), (30, 1, 6))
spawn_cube("NEXUS_Wall_East", (1500, 0, 250), (1, 30, 6))
spawn_cube("NEXUS_Wall_West", (-1500, 0, 250), (1, 30, 6))

# Simple cover blocks to give the player scale references.
spawn_cube("Cover_Block_A", (400, 250, 60), (2.0, 2.0, 1.2))
spawn_cube("Cover_Block_B", (-350, 450, 90), (1.5, 1.5, 1.8))
spawn_cube("Cover_Block_C", (250, -400, 75), (2.5, 1.5, 1.5))

player_start = unreal.EditorLevelLibrary.spawn_actor_from_class(
    unreal.PlayerStart, unreal.Vector(0, 0, 100), unreal.Rotator(0, 0, 0)
)
player_start.set_actor_label("NEXUS_PlayerStart")

game_mode_class = unreal.load_class(None, "/Script/NEXUSBattleRoyale.NEXUSGameModeBase")
if game_mode_class:
    world_settings = world.get_world_settings()
    world_settings.set_editor_property("default_game_mode", game_mode_class)
else:
    unreal.log_warning("NEXUSGameModeBase not loaded yet; set it in World Settings after compiling.")

unreal.EditorLevelLibrary.save_current_level()
unreal.log("NEXUS pre-lobby blockout created at " + MAP_PATH)
