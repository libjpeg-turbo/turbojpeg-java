add_executable(md5sum md5sum.c md5.c md5hl.c)
set_target_properties(md5sum PROPERTIES RUNTIME_OUTPUT_DIRECTORY
  ${CMAKE_BINARY_DIR}/test)
