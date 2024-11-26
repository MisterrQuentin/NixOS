final: prev: {
  ollama = prev.ollama.overrideAttrs (oldAttrs: rec {
    version = "0.4.2";
    src = prev.fetchFromGitHub {
      owner = "ollama";
      repo = "ollama";
      rev = "v${version}";
      hash = "sha256-O36ngdRsMph/qFZ+xbzkOtAcFag2uSDbyIf1/koX6eA=";
      fetchSubmodules = true;
    };

    vendorHash = "sha256-HWIKKXJKCG+B+sQRM3izVhT59qqnKfObDchFWocIfFk=";

    patches = [];

    preBuild = ''
      # disable uses of `git`, since nix removes the git directory
      export OLLAMA_SKIP_PATCHING=true
      
      # build llama.cpp libraries for ollama
      go generate ./...
    '';

    postPatch = ''
      # replace inaccurate version number with actual release version
      substituteInPlace version/version.go --replace-fail 0.0.0 '${version}'

      # apply ollama's patches to `llama.cpp` submodule
      for diff in llm/patches/*; do
        patch -p1 -d llm/llama.cpp < $diff || true
      done
    '';
  });
}
