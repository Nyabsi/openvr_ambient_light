include(${CMAKE_ROOT}/Modules/ExternalProject.cmake)

set(ImGui_ROOT ${CMAKE_SOURCE_DIR}/external/imgui)
set(ImPlot_ROOT ${CMAKE_SOURCE_DIR}/external/implot)
set(SimpleINI_ROOT ${CMAKE_SOURCE_DIR}/external/simpleini)
set(RenderDoc_ROOT ${CMAKE_SOURCE_DIR}/external/renderdoc)

# imgui & implot
add_library(ImGui STATIC
    ${ImGui_ROOT}/backends/imgui_impl_dx11.cpp
	${ImGui_ROOT}/backends/imgui_impl_win32.cpp
    ${ImGui_ROOT}/imgui.cpp
	${ImGui_ROOT}/imgui_demo.cpp
	${ImGui_ROOT}/imgui_draw.cpp
	${ImGui_ROOT}/imgui_tables.cpp
	${ImGui_ROOT}/imgui_widgets.cpp
	${ImGui_ROOT}/misc/cpp/imgui_stdlib.cpp
	# ImPlot
	${ImPlot_ROOT}/implot.cpp
	${ImPlot_ROOT}/implot_items.cpp
)

target_include_directories(ImGui PUBLIC ${ImGui_ROOT})
target_include_directories(ImGui PUBLIC ${ImPlot_ROOT})

# spdlog
add_subdirectory(spdlog)

# simpleini
add_library(SimpleINI STATIC
    ${SimpleINI_ROOT}/ConvertUTF.c
)

target_include_directories(SimpleINI PUBLIC ${SimpleINI_ROOT})

# rederdoc
add_library(renderdoc INTERFACE)

target_include_directories(renderdoc INTERFACE ${RenderDoc_ROOT})