from vllm import LLM, SamplingParams

# prompts = [
#     "Please write a long long story about Little Red Riding Hood.\n\
#     Include the main characters: Red Riding Hood, her grandmother, the wolf, and the woodsman.\n\
#     The story should be engaging, suitable for children, and follow the traditional fairy tale structure with a happy ending.",
# ]

prompts = [
    "Please write a long long story about Little Red Riding Hood.",
]
sampling_params = SamplingParams(
    temperature=0.8, top_p=0.95, max_tokens=1024, seed=42, ignore_eos=False
)

llm = LLM(
    model="/root/autodl-tmp/opt-6.7b",
    tensor_parallel_size=1,
    speculative_config={
        "model": "/root/autodl-tmp/opt-125m",
        "num_speculative_tokens": 5,
    },
)
outputs = llm.generate(prompts, sampling_params)

for output in outputs:
    prompt = output.prompt
    generated_text = output.outputs[0].text
    print(f"Prompt: {prompt!r}, Generated text: {generated_text!r}")

# from vllm.spec_decode.spec_decode_worker import acc_info
# print(f'proposal num:{acc_info.proposal_len}')
# print(f'accept num:{acc_info.accept_len}')
# print(f"accept_rate: {acc_info.accept_len/acc_info.proposal_len*100:.2f} ")


# nsys profile -o opt6-7-sd-5.nsys-rep --trace -fork-before-exec=true --cuda-graph-trace=node --cpuctxsw=yes --trace=cuda,nvtx python test-vllm.py
