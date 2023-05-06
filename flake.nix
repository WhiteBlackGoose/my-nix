{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }: {
    dotnetShell = sdks: tools: nixpkgs.mkShell rec {
      dotnetPkg = sdks nixpkgs.dotnetCorePackages;

      deps = with nixpkgs; [
        zlib
        zlib.dev
        openssl
        dotnetPkg
        (
          let 
            dt = (callPackage ./dotnet-tool.nix {});
          in
            dt.combineTools dotnetPkg (tools dt.tools)
        )
      ];

      NIX_LD_LIBRARY_PATH = with nixpkgs; lib.makeLibraryPath ([
        stdenv.cc.cc
      ] ++ deps);
      NIX_LD = "${nixpkgs.stdenv.cc.libc_bin}/bin/ld.so";
      packages = with nixpkgs; [ 
        omnisharp-roslyn
        netcoredbg
        msbuild
      ] ++ deps;

      shellHook = 
      ''
        DOTNET_ROOT="${dotnetPkg}";
        PATH="~/.dotnet/tools:$PATH";
      '';
    };
  };
}
