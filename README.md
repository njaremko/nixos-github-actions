# nixos-github-actions

I'm not happy with the GitHub Runner module in NixOS.

For one, [workDir just doesn't work](https://github.com/NixOS/nixpkgs/issues/289422). Further, I find the module hard to read and maybe overly cautious.

# issues

probably over/under-aggressively restarts, resets the agent, etc

# decisions

let systemd do normal dir stuff and not be fancy.

this means persistent storage just works.

This might not be as clean as clearing but also nixpkgs
is huge and my jobs need it for each run.

# support

I'll provide support for this when:
* GitHub Actions stops being garbage
* Azure supports ed25519 ssh keys
  
So, probably never.

I hope to permanently migrate off GitHub Actions, [soon](https://github.com/typhon-ci/typhon).

# seriously

GitHub Actions is trash:
- no configurable notifications
- runner is a nightmare
- runner is undocumented
- runner keeps its state and workdir together, and just labels it as the repo, not even in a dir
- really just excellent shoddy MS engineering as always