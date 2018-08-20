#include <stdint.h>
#include <string.h>
#include <windows.h>

#include "erl_nif.h"

static ERL_NIF_TERM clear_bin(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
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

static ERL_NIF_TERM get_self(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifPid caller;
    if(!enif_self(env, &caller))
        return enif_raise_exception(
            env, enif_make_atom(env, "badprocess")
        );

    return enif_make_pid(env, &caller);
}

static ERL_NIF_TERM async_process(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifPid caller;
    if(!enif_self(env, &caller))
        return enif_raise_exception(
            env, enif_make_atom(env, "badprocess")
        );

    Sleep(3000);

    if(!enif_send(
        env, &caller, NULL,
        enif_make_atom(env, "from_async_process"))
    ) return enif_raise_exception(
            env, enif_make_atom(env, "send_failed")
    );
}

static ERL_NIF_TERM async(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifPid caller;
    if(!enif_self(env, &caller))
        return enif_raise_exception(
            env, enif_make_atom(env, "badprocess")
        );

    return enif_schedule_nif(env, "async_process", ERL_NIF_DIRTY_JOB_IO_BOUND,
                             async_process, argc, argv);
}

static ERL_NIF_TERM clear_bin_async_process(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifPid caller;
    if(!enif_self(env, &caller))
        return enif_raise_exception(
            env, enif_make_atom(env, "badprocess")
        );

    ErlNifBinary buffer;
    if (!enif_inspect_binary(env, argv[0], &buffer))
        return enif_make_badarg(env);

    uint8_t* buf = (uint8_t*)(buffer.data);
    for (int i = 0; i < buffer.size; ++i)
        buf[i] = 0;

    if(!enif_send(
        env, &caller, NULL,
        enif_make_atom(env, "from_clear_bin_async_process"))
    ) return enif_raise_exception(
            env, enif_make_atom(env, "send_failed")
    );
}

static ERL_NIF_TERM clear_bin_async(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifPid caller;
    if(!enif_self(env, &caller))
        return enif_raise_exception(
            env, enif_make_atom(env, "badprocess")
        );

    return enif_schedule_nif(env, "clear_bin_async_process", ERL_NIF_DIRTY_JOB_IO_BOUND,
                             clear_bin_async_process, argc, argv);
}

int upgrade(ErlNifEnv* env, void** priv_data, void** old_priv_data, ERL_NIF_TERM load_info)
{
    return 0;
}

static ErlNifFunc nif_funcs[] = {
    {"clear_bin", 1, clear_bin},
    {"get_self", 0, get_self},
    {"async", 0, async},
    {"clear_bin_async", 1, clear_bin_async}
};

ERL_NIF_INIT(binnifcpy, nif_funcs, NULL, NULL, upgrade, NULL)
