{ stdenv
, icu
, udev
, mesa
, fontconfig
, gtk3
, libGL
, libglvnd
, libGLU
, jdk
, lib
, dotnet-sdk_8
, fetchurl
, desktop-file-utils
, xorg
, makeWrapper
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dotMemory";
  version = "2024.1.2";

  src = fetchurl {
    url = "https://download.jetbrains.com/resharper/dotUltimate.2024.1.2/JetBrains.dotMemory.linux-x64.2024.1.2.tar.gz";
    hash = "sha256-DyTNw84fl3VkWjvDigqzfTmgtNQII5AZdjGJ44jTOAs=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    makeWrapper
  ];

  installPhase = let

                    extraLdPath = [
                                icu
                                udev
                                xorg.libX11
                                xorg.libICE
                                xorg.libSM
                                mesa
                                fontconfig
                                gtk3
                                libGL
                                libglvnd
                                libGLU
                                stdenv.cc.cc
                                stdenv.cc.cc.lib
                                ];
   in ''
          #extra="${lib.makeLibraryPath extraLdPath}"
          #IFS=':'
          #for libpath in $extra; do
          #  ln -sf "$libpath"/* .
          #done
          #unset IFS

          mkdir -p $out/{bin,$pname}
          cp -a . $out/$pname

          rm -r linux-x64/dotnet
          ln -s ${dotnet-sdk_8} linux-x64/dotnet


          wrapProgram  "dotMemoryUI" \
            --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath extraLdPath}"

          #interp="$(cat $NIX_CC/nix-support/dynamic-linker)"
          #patchelf --set-rpath ${lib.makeLibraryPath extraLdPath} . --help
          #patchelf --set-interpreter $interp linux-x64/dotMemory

          #jar=$(find $out -name "skiko-awt-runtime-linux-x64*.jar")
          #${jdk}/bin/jar xvf $jar libskiko-linux-x64.so
          #patchelf --set-rpath ${lib.makeLibraryPath extraLdPath} libskiko-linux-x64.so
          #${jdk}/bin/jar uvf $jar libskiko-linux-x64.so
          #rm -f libskiko-linux-x64.so

   '';

  meta = with lib; {
    description = "dotMemory allows you to analyze memory usage in a variety of .NET and .NET Core applications";
    homepage = "https://www.jetbrains.com/dotmemory/";
    license = licenses.unfree;
    maintainers = with maintainers; [ zlepper ];
    platforms = platforms.linux;
    mainProgram = "dotMemoryUI";
  };
})
