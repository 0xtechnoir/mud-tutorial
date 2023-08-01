// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System } from "@latticexyz/world/src/System.sol";
import { Encounter, Encounterable, EncounterTrigger, EncounterData, MapConfig, Movable, Obstruction, Player, Position, Monster } from "../codegen/Tables.sol";
import { MonsterType } from "../codegen/Types.sol";
import { addressToEntityKey } from "../addressToEntityKey.sol";
import { positionToEntityKey } from "../positionToEntityKey.sol";

contract MapSystem is System {

  function spawn(uint32 x, uint32 y) public {

    // create a player entity using the message senders address as the key
    bytes32 player = addressToEntityKey(address(_msgSender()));
    
    // we could limit the number of players here as well
    require(!Player.get(player), "already spawned");

    // Constrain position to map size, wrapping around if necessary
    (uint32 width, uint32 height, ) = MapConfig.get();
    x = (x + width) % width;
    y = (y + height) % height;

    bytes32 position = positionToEntityKey(x, y);
    require(!Obstruction.get(position), "the space is obstructed");

    // when we spawn a new player we store state in separate tables (components) and associate them with the player entity rather than storing everything in a single contract
    Player.set(player, true);
    Position.set(player, x, y);
    Movable.set(player, true);
    Encounterable.set(player, true); // enable the player to enter encounters
  }

  function move(uint32 x, uint32 y) public {

    bytes32 player = addressToEntityKey(_msgSender());
    // ensure the player entity has the movable component
    require(Movable.get(player), "cannot move");
    // prevent player from moving during an encounter
    require(!Encounter.getExists(player), "Cannot move during an encounter");

    // retrieve the players current position
    (uint32 fromX, uint32 fromY) = Position.get(player);
    // if a players range is dynamic, could retrieve a value from a range component here instead of the hardcoded '1'
    require(distance(fromX, fromY, x, y) == 1, "can only move to adjacent spaces");

    // Constrain position to map size, wrapping around if necessary
    (uint32 width, uint32 height, ) = MapConfig.get();
    x = (x + width) % width;
    y = (y + height) % height;

    bytes32 position = positionToEntityKey(x, y);
    require(!Obstruction.get(position), "the space is obstructed");

    Position.set(player, x, y);

    if (Encounterable.get(player) && EncounterTrigger.get(position)) {
      uint256 rand = uint256(keccak256(abi.encode(player, position, blockhash(block.number -1), block.difficulty)));
      if (rand % 5 == 0) {
        startEncounter(player);
      }
    }
  }

  function distance(uint32 fromX, uint32 fromY, uint32 toX, uint32 toY) internal pure returns (uint32) {
    uint32 deltaX = fromX > toX ? fromX - toX : toX - fromX;
    uint32 deltaY = fromY > toY ? fromY - toY : toY - fromY;
    return deltaX + deltaY;
  }

  function startEncounter(bytes32 player) internal {
    // generate a psuedorandom number
    bytes32 monster = keccak256(abi.encode(player, blockhash(block.number -1), block.difficulty));
    // Use this to choose one of the enumerated monster options
    MonsterType monsterType = MonsterType((uint256(monster) % uint256(type(MonsterType).max)) + 1);
    Monster.set(monster, monsterType);
    // put the player entity into an encounter with the monster
    Encounter.set(player, EncounterData({ exists: true, monster: monster, catchAttempts: 0}));
  }

}
