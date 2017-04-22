cmake_minimum_required(VERSION 3.7)
project(SwiftMud)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES
        Sources/Context.swift
        Sources/CommandHandler.swift
        Sources/Connection.swift
        Sources/LoginHandler.swift
        Sources/main.swift
        Sources/Server.swift
        Sources/DungeonHandler.swift
        Sources/World.swift)

add_custom_target(SwiftMud
        COMMAND swift build
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        SOURCES ${SOURCE_FILES})
