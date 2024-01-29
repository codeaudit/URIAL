run_name=$1 

if [ "${run_name}" == "urial-tulu-70b" ]; then
    model_name="Llama-2-70b-urial"
    target_file="result_dirs/alpaca_eval/urial/llama-70b-urial.inst_help_v5-1k.json"
    ref_name="tulu-2-70b"
    ref_file="result_dirs/alpaca_eval/aligned/${ref_name}.json"
elif [ "${run_name}" == "urial-tulu-70b-dpo" ]; then 
    model_name="Llama-2-70b-urial"
    target_file="result_dirs/alpaca_eval/urial/llama-70b-urial.inst_help_v5-1k.json"
    ref_name="tulu-2-dpo-70b"
    ref_file="result_dirs/alpaca_eval/aligned/${ref_name}.json"
elif [ "${run_name}" == "urial-chatgpt" ]; then 
    model_name="Llama-2-70b-urial"
    target_file="result_dirs/alpaca_eval/urial/llama-70b-urial.inst_help_v5-1k.json"
    ref_name="gpt-3.5-turbo-0301"
    ref_file="result_dirs/alpaca_eval/aligned/${ref_name}.json"
elif [ "${run_name}" == "tulu-chatgpt" ]; then 
    model_name="tulu-2-dpo-70b"
    target_file="result_dirs/alpaca_eval/aligned/${model_name}.json"
    ref_name="gpt-3.5-turbo-0301"
    ref_file="result_dirs/alpaca_eval/aligned/${ref_name}.json"
elif [ "${run_name}" == "urial-gpt4" ]; then 
    model_name="Llama-2-70b-urial"
    target_file="result_dirs/alpaca_eval/urial/llama-70b-urial.inst_help_v5-1k.json"
    ref_name="gpt4_turbo"
    ref_file="result_dirs/alpaca_eval/aligned/${ref_name}.json"
elif [ "${run_name}" == "tulu-gpt4" ]; then 
    model_name="tulu-2-dpo-70b"
    target_file="result_dirs/alpaca_eval/aligned/${model_name}.json"
    ref_name="gpt4_turbo"
    ref_file="result_dirs/alpaca_eval/aligned/${ref_name}.json"
elif [ "${run_name}" == "urial-tulu-7b" ]; then
    model_name="Llama-2-7b-urial"
    target_file="result_dirs/alpaca_eval/urial/llama-7b-urial.inst_help_v5-1k.json"
    ref_name="tulu-2-7b"
    ref_file="result_dirs/alpaca_eval/aligned/${ref_name}.json"
elif [ "${run_name}" == "urial-tulu-7b-dpo" ]; then
    model_name="Llama-2-7b-urial"
    target_file="result_dirs/alpaca_eval/urial/llama-7b-urial.inst_help_v5-1k.json"
    ref_name="tulu-2-dpo-7b"
    ref_file="result_dirs/alpaca_eval/aligned/${ref_name}.json"
elif [ "${run_name}" == "urial-llama-70b" ]; then
    model_name="Llama-2-70b-urial"
    target_file="result_dirs/alpaca_eval/urial/llama-70b-urial.inst_help_v5-1k.json"
    ref_name="Llama-2-70b-chat-hf"
    ref_file="result_dirs/alpaca_eval/aligned/${ref_name}.json"
elif [ "${run_name}" == "urial-llama-7b" ]; then
    model_name="Llama-2-7b-urial"
    target_file="result_dirs/alpaca_eval/urial/llama-7b-urial.inst_help_v5-1k.json"
    ref_name="Llama-2-7b-chat-hf"
    ref_file="result_dirs/alpaca_eval/aligned/${ref_name}.json"
elif [ "${run_name}" == "urial-mistral" ]; then
    model_name="mistral-urial"
    target_file="result_dirs/alpaca_eval/urial/mistral-urial.inst_help_v5-1k.json"
    ref_name="Mistral-7B-Instruct-v0.1"
    ref_file="result_dirs/alpaca_eval/aligned/${ref_name}.json"

elif [ "${run_name}" == "urial-1k-llama-70b" ]; then
    model_name="Llama-2-70b-urial-1k"
    target_file="result_dirs/alpaca_eval/vllm_urial-inst_help_v5-1k/rp=1_N=1_T=0.3/Llama-2-70b-hf.json"
    ref_name="Llama-2-70b-chat-hf"
    ref_file="result_dirs/alpaca_eval/aligned/${ref_name}.json"
elif [ "${run_name}" == "urial-1k-llama-7b" ]; then
    model_name="Llama-2-7b-urial-1k"
    target_file="result_dirs/alpaca_eval/vllm_urial-inst_help_v5-1k/rp=1_N=1_T=0.3/Llama-2-7b-hf.json"
    ref_name="Llama-2-7b-chat-hf"
    ref_file="result_dirs/alpaca_eval/aligned/${ref_name}.json"
else 
    echo "mode not supported"
    exit 1
fi


     
eval_folder="evaluate/results/ref=${ref_name}/"
mkdir -p $eval_folder

n_shards=8
shard_size=101
start_gpu=0
for ((start = 0, end = (($shard_size)), gpu = $start_gpu; gpu < $n_shards+$start_gpu; start += $shard_size, end += $shard_size, gpu++)); do
    eval_file="${eval_folder}/${model_name}.$start-$end.json"
    python evaluate/eval.py \
        --action eval \
        --mode pairwise \
        --eval_template evaluate/eval_template_pairwise.md \
        --model_output_file $target_file \
        --ref_output_file $ref_file \
        --eval_output_file $eval_file \
        --start_idx $start --end_idx $end  &
done

# Wait for all background processes to finish
wait

# Run the merge results script after all evaluation scripts have completed
python evaluate/merge_results.py $eval_folder $model_name