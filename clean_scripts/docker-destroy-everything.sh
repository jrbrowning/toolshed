#!/bin/bash

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                   Docker Nuclear Cleanup Script (toolshed)                ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# This script is designed to aggressively clean up all local Docker artifacts
# in order to reclaim disk space. The primary use-case is for developers
# running local AI models (e.g., LLMs, vector DBs, GPU workloads) inside Docker
# containers, which can rapidly consume disk resources.
#
# ❗ What this script does:
#   • Stops all running Docker containers
#   • Removes all containers (running or stopped)
#   • Removes all Docker images (used or unused)
#   • Removes all Docker volumes and networks
#   • Prunes builder cache and system metadata
#   • Calculates reclaimed disk space
#
# ⚠️ THIS WILL DELETE NEARLY ALL LOCAL DOCKER DATA.
# You will need to re-pull images, recreate volumes, etc.
#
# 🔐 A confirmation prompt is included by default (default = No).
#
# 📌 Manual Final Step (optional):
# For *complete* cleanup including all unused images across all projects,
# you may run the following manually:
#
#     docker system prune -a
#
# This is not included in the script for safety reasons.
# ------------------------------------------------------------------------------

read -p "Are you sure you want to destroy all Docker data? [y/N] " confirm
confirm=${confirm:-N}
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted. No changes made."
    exit 0
fi

# Function to stop all running containers
stop_containers() {
    running_containers=$(docker ps -q)
    if [ -n "$running_containers" ]; then
        echo "Stopping all running Docker containers..."
        docker stop $running_containers
        if [ $? -ne 0 ]; then
            echo "Failed to stop Docker containers."
            exit 1
        fi
    else
        echo "No running containers to stop."
    fi
}

# Function to remove all containers
remove_containers() {
    all_containers=$(docker ps -a -q)
    if [ -n "$all_containers" ]; then
        echo "Removing all Docker containers..."
        docker rm $all_containers
        if [ $? -ne 0 ]; then
            echo "Failed to remove Docker containers."
            exit 1
        fi
    else
        echo "No containers to remove."
    fi
}

# Function to remove all images
remove_images() {
    all_images=$(docker images -q)
    if [ -n "$all_images" ]; then
        echo "Removing all Docker images..."
        docker rmi $all_images
        if [ $? -ne 0 ]; then
            echo "Failed to remove Docker images."
            exit 1
        fi
    else
        echo "No images to remove."
    fi
}

# Function to remove all volumes
remove_volumes() {
    all_volumes=$(docker volume ls -q)
    if [ -n "$all_volumes" ]; then
        echo "Removing all Docker volumes..."
        docker volume rm $all_volumes
        if [ $? -ne 0 ]; then
            echo "Failed to remove Docker volumes."
            exit 1
        fi
    else
        echo "No volumes to remove."
    fi
}

# Function to remove all networks
remove_networks() {
    all_networks=$(docker network ls -q)
    if [ -n "$all_networks" ]; then
        echo "Removing all Docker networks..."
        docker network rm $all_networks
        if [ $? -ne 0 ]; then
            echo "Failed to remove Docker networks."
            exit 1
        fi
    else
        echo "No networks to remove."
    fi
}

# Function to prune the Docker system
prune_system() {
    echo "Pruning Docker system..."
    docker system prune -af --volumes
    if [ $? -ne 0 ]; then
        echo "Failed to prune Docker system."
        exit 1
    fi
}

# Function to prune Docker builder cache
prune_builder_cache() {
    echo "Pruning Docker builder cache..."
    docker builder prune -f
    if [ $? -ne 0 ]; then
        echo "Failed to prune Docker builder cache."
        exit 1
    fi
}

# Function to prune unused Docker images
prune_images() {
    echo "Pruning unused Docker images..."
    docker image prune -f
    if [ $? -ne 0 ]; then
        echo "Failed to prune Docker images."
        exit 1
    fi
}

# Function to prune stopped containers
prune_containers() {
    echo "Pruning stopped Docker containers..."
    docker container prune -f
    if [ $? -ne 0 ]; then
        echo "Failed to prune Docker containers."
        exit 1
    fi
}

# Function to prune unused volumes
prune_volumes() {
    echo "Pruning unused Docker volumes..."
    docker volume prune -f
    if [ $? -ne 0 ]; then
        echo "Failed to prune Docker volumes."
        exit 1
    fi
}

# Function to remove build cache
remove_build_cache() {
    echo "Removing all Docker build cache..."
    docker builder prune --all -f
    if [ $? -ne 0 ]; then
        echo "Failed to remove Docker build cache."
        exit 1
    fi
}

# Function to run final system prune interactively
final_system_prune() {
    echo "Running final 'docker system prune' interactively to remove any remaining resources..."
    docker system prune
    if [ $? -ne 0 ]; then
        echo "Final 'docker system prune' failed."
        exit 1
    fi
}

# Function to get the current Docker disk usage
get_docker_usage() {
    docker system df --format '{{.Size}}' | awk '{print $1}'
}

# Get memory usage before cleanup
initial_usage=$(get_docker_usage)
echo "Initial Docker disk usage: $initial_usage"

# Run functions in order
stop_containers
remove_containers
remove_images
remove_volumes
remove_networks
prune_system
prune_builder_cache
prune_images
prune_containers
prune_volumes
remove_build_cache

# Get memory usage after cleanup
final_usage=$(get_docker_usage)
echo "Final Docker disk usage: $final_usage"

# Calculate memory cleared
memory_cleared=$(echo "$initial_usage - $final_usage" | bc)
echo "Total memory cleared: ${memory_cleared} GB"

# Run interactive final prune
final_system_prune

echo "Docker cleanup completed successfully!"