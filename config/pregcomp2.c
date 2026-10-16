#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

int main() {
    SV* sv = newSViv(0);
    void* rx = pregcomp(sv, 0);
}
