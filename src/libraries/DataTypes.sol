// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

enum ExecMode {
    JIT,
    PERSISTENT
}

struct Requirement {
    string ram;
    string disk;
    uint256 timeout;
    uint256 cpu; // how many CPU cores are required
    bool gpu; // whether GPU is required
}

struct Specification {
    string version; // version of the Specification schema(eg. currently only "1.0.0" available)
    string name; // name of the computing task
    string description; // description of the computing task
    string environment; // environment of the computing task, e.g. "python:3.7"
    string repository; // repository of the computing task
    string repoTag; // tag of the repository, e.g. "release-2.0"
    string license; // license of the computing task
    string entrypoint; // entrypoint of the computing task
    Requirement requirement; // requirement of the computing task, e.g. CPU, RAM, GPU, etc.
    uint256 royalty; // royalty fee rate, in basis points, e.g. 5 means 0.05%
    string apiABIs; // declaration of the abis to request and get response for other contracts
        // to call, e.g. " [{"request":"calculate(uint256)","getResponse":"getResponse(uint256)"}]"
    ExecMode execMode; // how the computing task should be executed in the worker node, JIT or
        // PERSISTENT
}

struct Commitment {
    address requester;
    address callbackAddress;
    uint256 payment;
    uint256 cancelExpiration;
}
