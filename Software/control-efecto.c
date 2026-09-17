#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

#define UIO_DEVICE "/dev/uio0"
#define MAP_SIZE   0x10000

int main(int argc, char *argv[])
{
    int fd;
    void *map_base;
    volatile unsigned int *gpio_data;
    int efecto;

    if (argc != 2) {
        printf("Uso: %s <efecto>\n", argv[0]);
        printf("0 = Sin efecto\n");
        printf("1 = Tremolo\n");
        printf("2 = Reverb\n");
        printf("3 = Chorus\n");
        printf("4 = Delay\n");
        printf("5 = Flanger\n");
        return 1;
    }

    efecto = atoi(argv[1]);

    if (efecto < 0 || efecto > 5) {
        printf("Error: efecto debe estar entre 0 y 5\n");
        return 1;
    }

    fd = open(UIO_DEVICE, O_RDWR);

    if (fd < 0) {
        perror("Error abriendo /dev/uio0");
        return 1;
    }

    map_base = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

    if (map_base == MAP_FAILED) {
        perror("Error en mmap");
        close(fd);
        return 1;
    }

    gpio_data = (volatile unsigned int *)map_base;

    *gpio_data = efecto;

    printf("Efecto seleccionado: %d\n", efecto);

    munmap(map_base, MAP_SIZE);
    close(fd);

    return 0;
}
