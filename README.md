# TFG – Cora Z7 Audio Effects

Trabajo de Fin de Grado centrado en el desarrollo de un sistema de procesamiento de audio en tiempo real sobre la **Digilent Cora Z7-07S**, basada en la arquitectura **Xilinx Zynq-7000**.

El sistema combina un entorno **Linux embebido mediante PetaLinux** con una arquitectura de procesamiento de audio implementada en **VHDL** sobre la lógica programable de la FPGA.

## Funcionalidades

El sistema permite aplicar en tiempo real cinco efectos de audio:

- Tremolo
- Reverb
- Chorus
- Delay
- Flanger

La señal de audio se adquiere mediante un **ADC PCM1808** y se reproduce mediante un **DAC PCM5102**, utilizando comunicación I2S.

La selección de los efectos se realiza desde el sistema Linux mediante **UIO y AXI GPIO**, permitiendo finalmente controlar el procesamiento desde una **interfaz web** a través de una conexión Ethernet.

## Contenido del repositorio

El repositorio incluye los principales archivos desarrollados durante el proyecto:

- Código VHDL del sistema de audio y de los efectos.
- Máquina de estados para la selección de efectos.
- Archivo de restricciones de la Cora Z7-07S.
- Configuración del Device Tree y UIO.
- Aplicación de control desde Linux.
- Scripts CGI y de inicialización.
- Interfaz web para la selección de efectos.

## Autor

**Francisco Martín Cuscurita**

Trabajo de Fin de Grado – Universidad Politécnica de Madrid (UPM), 2026.
