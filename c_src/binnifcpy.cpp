#include "erl_nif.h"

#include <string.h>
#include <stdint.h>

static ERL_NIF_TERM byte_array_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    argc = argc; // for unused variable warning

    ErlNifBinary buffer;
    
    if (!enif_inspect_binary(env, argv[0], &buffer))
        return enif_make_badarg(env);

    uint8_t* buf = (uint8_t*)(buffer.data);
    for (int i = 0; i < buffer.size; ++i)
        buf[i] = 0;
    return enif_make_binary(env, &buffer);
}

static ErlNifFunc nif_funcs[] = {
    {"byte_array", 1, byte_array_nif}
};

ERL_NIF_INIT(binnifcpy, nif_funcs, NULL, NULL, NULL, NULL)
