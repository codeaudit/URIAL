version=$1
rp=$2
N=$3
T=$4
output_dir="result_dirs/alpaca_eval/vllm_urial-${version}/rp=${rp}_N=${N}_T=${T}/"
mkdir -p $output_dir
gpu=0,1,2,3
tps=4
CUDA_VISIBLE_DEVICES=$gpu python src/unified_infer.py \
    --urial $version \
    --download_dir /net/nfs/s2-research/llama2/ \
    --model_name meta-llama/Llama-2-70b-hf \
    --tensor_parallel_size $tps \
    --dtype bfloat16 \
    --data_name alpaca_eval --num_outputs $N \
    --top_p 1.0 --temperature $T  --repetition_penalty $rp --batch_size 8 --max_tokens 2048 \
    --output_folder $output_dir/ \
    --overwrite  
 