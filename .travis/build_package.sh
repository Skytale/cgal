#!/bin/bash
set -e
IFS=$' '
ROOT="$PWD/../"
NEED_3D=0
for ARG in $(echo "$@")
do
  if [ "$ARG" = "CHECK" ]
	then
    zsh $ROOT/Scripts/developer_scripts/test_merge_of_branch HEAD

  	#parse current matrix and check that no package has been forgotten
	  old_IFS=$IFS
	  IFS=$'\n'
	  COPY=0
	  MATRIX=()
	  for LINE in $(cat "$PWD/packages.txt")
	  do
	        MATRIX+="$LINE "
	  done
	
	  PACKAGES=()
	  cd ..
  	for f in *
	  do
	    if [ -d  "$f/examples/$f" ] || [ -d  "$f/test/$f" ] || [ -d  "$f/demo/$f" ]
	        then
	                PACKAGES+="$f "
	        fi
	  done	
	
	  DIFFERENCE=$(echo ${MATRIX[@]} ${PACKAGES[@]} | tr ' ' '\n' | sort | uniq -u)
	  IFS=$old_IFS
	  if [ "${DIFFERENCE[0]}" != "" ]
	  then
	        echo "The matrix and the actual package list differ : ."
					echo ${DIFFERENCE[*]}
	        exit 1
	  fi
	  echo "Matrix is up to date."
    exit 0
	fi
	EXAMPLES="$ARG/examples/$ARG"
	TEST="$ARG/test/$ARG" 
	DEMOS=$ROOT/$ARG/demo/*
  if [ "$ARG" = AABB_tree ] || [ "$ARG" = Alpha_shapes_3 ] ||\
     [ "$ARG" = Circular_kernel_3 ] || [ "$ARG" = Linear_cell_complex ] ||\
     [ "$ARG" = Periodic_3_triangulation_3 ] || [ "$ARG" = Principal_component_analysis ] ||\
     [ "$ARG" = Surface_mesher ] || [ "$ARG" = Triangulation_3 ]; then
    NEED_3D=1
  fi

	if [ -d "$ROOT/$EXAMPLES" ]
	then
	  cd $ROOT/$EXAMPLES
	  mkdir -p build
	  cd build
	  cmake -DCGAL_DIR="$ROOT/build" -DCMAKE_CXX_FLAGS_RELEASE="-DCGAL_NDEBUG" ..
	  make -j2
  elif [ "$ARG" != Polyhedron_demo ]; then
    echo "No example found for $ARG"
	fi

	if [ -d "$ROOT/$TEST" ]
	then
	  cd $ROOT/$TEST
	  mkdir -p build
	  cd build
	  cmake -DCGAL_DIR="$ROOT/build" -DCMAKE_CXX_FLAGS_RELEASE="-DCGAL_NDEBUG" ..
  	make -j2
  elif [ "$ARG" != Polyhedron_demo ]; then
    echo "No test found for $ARG"
	fi
  #Packages like Periodic_3_triangulation_3 contain multiple demos
  for DEMO in $DEMOS; do
    DEMO=${DEMO#"$ROOT"}
    echo $DEMO
  	#If there is no demo subdir, try in GraphicsView
    if [ ! -d "$ROOT/$DEMO" ] || [ ! -f "$ROOT/$DEMO/CMakeLists.txt" ]; then
     DEMO="GraphicsView/demo/$ARG"
    fi
	  if [ "$ARG" != Polyhedron ] && [ -d "$ROOT/$DEMO" ]
  	then
      if [ $NEED_3D = 1 ]; then
    	  cd $ROOT/$DEMO
        #install libqglviewer
        git clone --depth=1 https://github.com/GillesDebunne/libQGLViewer.git ./qglviewer
        cd ./qglviewer/QGLViewer
        #use qt5 instead of qt4
        export QT_SELECT=5
        qmake NO_QT_VERSION_SUFFIX=yes
        make -j2
        if [ ! -f libQGLViewer.so ]; then
          echo "libQGLViewer.so not made"
          exit 1
        else
          echo "QGLViewer built successfully"
        fi
        #end install qglviewer
      fi
	    cd $ROOT/$DEMO
	    mkdir -p build
	    cd build
      if [ $NEED_3D = 1 ]; then
	      cmake -DCGAL_DIR="$ROOT/build" -DQGLVIEWER_INCLUDE_DIR="$ROOT/$DEMO/qglviewer" -DQGLVIEWER_LIBRARIES="$ROOT/$DEMO/qglviewer/QGLViewer/libQGLViewer.so" -DCMAKE_CXX_FLAGS_RELEASE="-DCGAL_NDEBUG" ..
      else
        cmake -DCGAL_DIR="$ROOT/build" -DCMAKE_CXX_FLAGS_RELEASE="-DCGAL_NDEBUG" ..
      fi
	    make -j2
    elif [ "$ARG" != Polyhedron_demo ]; then
      echo "No demo found for $ARG"
	  fi
  done
  if [ "$ARG" = Polyhedron_demo ]; then
    cd "$ROOT/Polyhedron/demo/Polyhedron"
    #install libqglviewer
    git clone --depth=1 https://github.com/GillesDebunne/libQGLViewer.git ./qglviewer
    cd ./qglviewer/QGLViewer
    #use qt5 instead of qt4
    export QT_SELECT=5
    qmake NO_QT_VERSION_SUFFIX=yes
    make -j2
    if [ ! -f libQGLViewer.so ]; then
      echo "libQGLViewer.so not made"
      exit 1
    fi
    #end install qglviewer
    cd "$ROOT/Polyhedron/demo/Polyhedron"
    mkdir -p ./build
    cd ./build
    cmake -DCGAL_DIR="$ROOT/build" -DQGLVIEWER_INCLUDE_DIR="$ROOT/Polyhedron/demo/Polyhedron/qglviewer" -DQGLVIEWER_LIBRARIES="$ROOT/Polyhedron/demo/Polyhedron/qglviewer/QGLViewer/libQGLViewer.so" -DCMAKE_CXX_FLAGS_RELEASE="-DCGAL_NDEBUG" ..
    make -j2
  fi  
done
