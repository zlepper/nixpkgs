{ lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  buildGoModule,
  dotnetCorePackages,
}:
let
  version = "4.0.5907";
  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-functions-core-tools";
    rev = version;
    hash = "sha256-Tg4OpZLhLUYSw1MKMNI7RsE1dWJB/RRmNG4pIlnPIEU=";
  };
  gozip = buildGoModule {
    pname = "gozip";
    inherit version;
    src = src + "/tools/go/gozip";
    vendorHash = null;
  };
in
buildDotnetModule rec {
  pname = "azure-functions-core-tools";
  inherit src version;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;
  nugetDeps = ./deps.nix;
  useDotnetFromEnv = false;
  executables = [ "func" ];

  postPatch = ''
    substituteInPlace src/Azure.Functions.Cli/Common/CommandChecker.cs \
      --replace-fail "CheckExitCode(\"/bin/bash" "CheckExitCode(\"${stdenv.shell}"
  '';

  postInstall = ''
    mkdir -p $out/bin
    ln -s ${gozip}/bin/gozip $out/bin/gozip
  '';

  meta = with lib; {
    homepage = "https://github.com/Azure/azure-functions-core-tools";
    description = "Command line tools for Azure Functions";
    license = licenses.mit;
    maintainers = with maintainers; [ mdarocha detegr ];
    platforms = ["x86_64-linux" "aarch64-darwin" "x86_64-darwin"];
  };
}
