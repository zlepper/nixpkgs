{
  lib,
  buildPythonPackage,
  fetchPypi,
  mesa,
}:

buildPythonPackage rec {
  pname = "pyqt5-sip";
  version = "12.13.0";

  src = fetchPypi {
    pname = "PyQt5_sip";
    inherit version;
    hash = "sha256-fzIdr4S5ydvKYbgOHvN72v/A6TMS7a4s19oluVOXHZE=";
  };

  # There is no test code and the check phase fails with:
  # > error: could not create 'PyQt5/sip.cpython-38-x86_64-linux-gnu.so': No such file or directory
  doCheck = false;
  pythonImportsCheck = [ "PyQt5.sip" ];

  meta = with lib; {
    description = "Python bindings for Qt5";
    homepage = "https://www.riverbankcomputing.com/software/sip/";
    license = licenses.gpl3Only;
    inherit (mesa.meta) platforms;
    maintainers = with maintainers; [ sander ];
  };
}
