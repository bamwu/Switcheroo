//
//  main.m
//  Switcheroo
//
//  Created by BAMWU on 3/25/25.
//

#import <stdio.h>
#import <stdlib.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <unistd.h>
#import <string.h>
#include <libgen.h>  // Needed for dirname()
#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {
    char arch[256];
    size_t size = sizeof(arch);

    // Get the machine architecture
    if (sysctlbyname("hw.machine", arch, &size, NULL, 0) != 0) {
        perror("sysctlbyname failed");
        return 1;
    }

    // Log architecture to Desktop
    FILE *logFile = fopen(getenv("HOME") ? strcat(getenv("HOME"), "/Desktop/switcheroo-log.txt") : "switcheroo-log.txt", "w");
    if (logFile) {
        fprintf(logFile, "Detected architecture: %s\n", arch);
        fclose(logFile);
    }

    // Determine correct binary
    char execPath[1024];
    if (strcmp(arch, "arm64") == 0) {
        snprintf(execPath, sizeof(execPath), "%s/arm64/Switcheroo", dirname(argv[0]));
    } else {
        snprintf(execPath, sizeof(execPath), "%s/x64/Switcheroo", dirname(argv[0]));
    }

    // Execute the correct binary
    execv(execPath, argv);

    // If execv fails, log the error
    perror("execv failed");
    return 1;
}

