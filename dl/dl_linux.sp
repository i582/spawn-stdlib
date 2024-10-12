module dl

// On Linux we need to link to dl to get dlopen/dlsym/dlclose.
#[library("dl")]
