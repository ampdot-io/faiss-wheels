function build_faiss {
    echo $PWD
    if [ -n "$IS_OSX" ]; then
        local with_blas="-framework Accelerate"
    else
        local with_blas="-pthread -lgfortran -static-libgfortran -l:libopenblas.a"
    fi
    (./configure \
        --without-cuda \
        --with-blas="$with_blas" \
        && make -j4 \
        && make install)
}


function pre_build {
    build_swig
    if [ -n "$IS_OSX" ]; then
        brew install libomp llvm
        export CC="/usr/local/opt/llvm/bin/clang"
        export CXX="/usr/local/opt/llvm/bin/clang++"
    else
        build_openblas
    fi
    (cd $REPO_DIR && build_faiss)
}

function run_tests {
    if [ ! -n "$IS_OSX" ]; then
        apt-get update \
            && apt-get install -y libgfortran3 \
            && rm -rf /var/lib/apt/lists/*
    fi
    python --version
    python -c "import faiss"
}
