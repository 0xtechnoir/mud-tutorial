import { overridableComponent } from "@latticexyz/recs";
import { SetupNetworkResult } from "./setupNetwork";

export type ClientComponents = ReturnType<typeof createClientComponents>;

export function createClientComponents({ components }: SetupNetworkResult) {
  return {
    ...components,
    // define components that can be overriden in the client. The actual overiding logic is implemented in createSystemCalls.ts
    Player: overridableComponent(components.Player),
    Position: overridableComponent(components.Position),
  };
}
