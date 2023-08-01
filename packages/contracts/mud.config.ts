import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  enums: {
    MonsterType: ["None", "Eagle", "Rat", "Caterpillar"],
    TerrainType: ["None", "TallGrass", "Boulder"],
    MonsterCatchResult: ["Missed", "Caught", "Fled"],
  },
  tables: {
    MonsterCatchAttempt: {
      ephemeral: true,
      dataStruct: false,
      keySchema: {
        encounter: "bytes32",
      },
      schema: {
        result: "MonsterCatchResult",
      },
    },
    Monster: "MonsterType",
    Encounter: {
      keySchema: {
        player: "bytes32",
      },
      schema: {
        exists: "bool",
        monster: "bytes32",
        catchAttempts: "uint256",
      },
    },
    OwnedBy: "bytes32",
    EncounterTrigger: "bool",
    Encounterable: "bool",
    MapConfig: {
      keySchema: {},
      dataStruct: false,
      schema: {
        width: "uint32",
        height: "uint32",
        terrain: "bytes",
      },
    },
    Movable: "bool",
    Obstruction: "bool",
    Player: "bool",
    Position: {
      dataStruct: false,
      schema: {
        x: "uint32",
        y: "uint32",
      }
    }
  },
});
