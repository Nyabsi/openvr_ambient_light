cmake_minimum_required(VERSION 3.20)

if (POLICY CMP0141)
  cmake_policy(SET CMP0141 NEW)
  set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
endif()

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

project(openvr_ambient_light)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(OpenVR_ROOT ${CMAKE_SOURCE_DIR}/external/openvr)
find_package(OpenVR REQUIRED)

# Include rest of the CMake bindings
add_subdirectory(external)

find_program(FXC fxc REQUIRED)

set(SHADER_DIR ${CMAKE_SOURCE_DIR}/shaders)
set(GEN_DIR    ${CMAKE_BINARY_DIR}/generated/shaders)
set(BIN_DIR    ${CMAKE_BINARY_DIR}/shader_bin)

file(GLOB_RECURSE HLSL_SHADERS CONFIGURE_DEPENDS
    ${SHADER_DIR}/*.hlsl
)

set(GENERATED_HEADERS)

foreach(SHADER ${HLSL_SHADERS})

    file(RELATIVE_PATH REL ${SHADER_DIR} ${SHADER})
    
    get_filename_component(BASE_NAME ${REL} NAME_WE)
    
    string(REPLACE "/" "_" BASE_NAME ${BASE_NAME})
    string(REPLACE "\\" "_" BASE_NAME ${BASE_NAME})
    
    set(OUT "${GEN_DIR}/${BASE_NAME}.h")
    set(BIN "${BIN_DIR}/${BASE_NAME}.bin")

    add_custom_command(
        OUTPUT ${OUT}
        
        COMMAND ${CMAKE_COMMAND} -E make_directory ${GEN_DIR}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${BIN_DIR}
        
        COMMAND ${FXC}
            -T cs_5_0
            -E main
            -Fo ${BIN}
            ${SHADER}
            
        COMMAND powershell -ExecutionPolicy Bypass
            -File ${CMAKE_SOURCE_DIR}/scripts/hlsl2bin.ps1
            -InputPath  "${BIN}"
            -OutputPath "${OUT}"
            -Name       "${BASE_NAME}"

        DEPENDS ${SHADER} ${CMAKE_SOURCE_DIR}/scripts/hlsl2bin.ps1
        VERBATIM
    )

    list(APPEND GENERATED_HEADERS ${OUT})

endforeach()

set(SOURCES
    "src/main.cpp"
    "src/d3d11_renderer.cpp"
    "src/settings_menu.cpp"
    "src/settings_manager.cpp"
    "src/ambient_light_sampler.cpp"
    "src/adalight_led_interface.cpp"
)

add_executable(openvr_ambient_light WIN32 ${SOURCES})

target_sources(openvr_ambient_light PRIVATE ${GENERATED_HEADERS})

target_include_directories(openvr_ambient_light PRIVATE
    ${CMAKE_BINARY_DIR}/generated
)

add_custom_target(shader_headers ALL
    DEPENDS ${GENERATED_HEADERS}
)

if (UNIX AND NOT APPLE)
    set_target_properties(openvr_ambient_light PROPERTIES
        BUILD_RPATH "$ORIGIN"
        INSTALL_RPATH "$ORIGIN"
        INSTALL_RPATH_USE_LINK_PATH FALSE
    )
endif()

target_include_directories(openvr_ambient_light PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)

# Windows executable icon
if (WIN32)
    target_sources(openvr_ambient_light PRIVATE "resources/openvr_ambient_light.rc")
endif()

target_compile_features(openvr_ambient_light PUBLIC cxx_std_20)

target_link_libraries(openvr_ambient_light
    PRIVATE
        OpenVR::API
        ImGui
        spdlog_header_only
        SimpleINI
        renderdoc
        d3d11 dxgi dxguid uxtheme pathcch onecore
)