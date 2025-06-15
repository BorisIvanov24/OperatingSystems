#include <fcntl.h>
#include <sys/stat.h>
#include <stdint.h>
#include <err.h>
#include <unistd.h>

struct pair
{
    uint32_t start;
    uint32_t end;
};

int main(int argc, char* argv[])
{
        if(argc != 4)
        {
        errx(1, "Expected 3 arguments!");
        }

    int fd1 = open(argv[1], O_RDONLY);

        if(fd1 < 0)
        {
        err(1, "Could not open file");
        }

        int fd2 = open(argv[2], O_RDONLY);

        if(fd2 < 0)
        {
            err(1, "Could not open file");
        }

        int fd3 = open(argv[3], O_WRONLY | O_CREAT, 0644);

        if(fd3 < 0)
        {
            err(1, "Could not open file");
        }

        struct stat info;

    if(fstat(fd1, &info) < 0)
    {
        err(1, "Could not stat file");
    }

    int numOfPairs = info.st_size / sizeof(struct pair);
    struct pair curPair;

    for(int i=0;i<numOfPairs;i++)
    {
        int bytes = read(fd1, &curPair, sizeof(curPair));

        if(bytes < 0)
        {
            err(1, "Could not read");
        }

        if(lseek(fd2, curPair.start * sizeof(uint32_t), SEEK_SET) < 0)
        {
            err(1, "Could not lseek");
        }

        uint32_t buffer;
        uint32_t numbersDone = 0;

        while(numbersDone != curPair.end)
        {
            bytes = read(fd2, &buffer, sizeof(buffer));

            if(bytes < 0)
            {
               err(1, "Could not read");
            }

            int bytesWritten = write(fd3, &buffer, sizeof(buffer));

            if(bytesWritten < 0)
            {
                err(1, "Could not write");
            }

            numbersDone++;
        }

    }

        return 0;
}
