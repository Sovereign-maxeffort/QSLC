from importlib import import_module
from pathlib import Path
import py_compile

import pytest


APP_FILES = (
    "qslc_dashboard_app.py",
    "qsls_dashboard_app.py",
    "streamlit_app.py",
)


@pytest.mark.parametrize("module_name", ("streamlit", "pandas"))
def test_runtime_dependency_is_installed(module_name):
    assert import_module(module_name) is not None


@pytest.mark.parametrize("app_path", APP_FILES)
def test_dashboard_source_compiles(app_path, tmp_path):
    source = Path(app_path)
    assert source.is_file()
    py_compile.compile(
        str(source),
        cfile=str(tmp_path / f"{source.stem}.pyc"),
        doraise=True,
    )
