import math
from multiprocessing import Pool

def calculate_expression_value(args):
    beta, p, alpha, m, n = args
    if p < alpha - 1:
        raise ValueError("p must be greater than or equal to alpha - 1")

    numerator1 = beta - 1
    denominator1 = math.comb(p, alpha - 1)
    term1 = numerator1 / denominator1

    numerator2 = (p + 1) * (alpha - 1)
    denominator2 = alpha
    term2 = numerator2 / denominator2

    return term1 * math.comb(m, alpha) + term2 * n

def calculate_roman_bounds(params):
    m, n, s, t = params
    results = {}

    for alpha in range(1, s + 1):
        for beta in range(1, t + 1):
            for i in range(1, m + 1):
                for j in range(1, n + 1):

                    min_result = float('inf')
                    min_p = None

                    for p in range(alpha - 1, i + 1):
                        result = calculate_expression_value((beta, p, alpha, i, j))
                        if result < min_result and math.isfinite(result):  # Check if result is finite
                            min_result = result
                            min_p = p

                    # Handle infinite result
                    if not math.isfinite(min_result):
                        min_result = int(1e9)  # Assign a large integer value

                    # Ensure result is integer
                    min_result = int(min_result)

                    if min_result != 1000000000:  # Exclude Zarankiewicz number if it equals 1000000000
                        results[(i, j, alpha, beta)] = min_result

    return results

if __name__ == '__main__':
    # Define parameters
    max_m = 20
    max_n = 20
    max_s = 20
    max_t = 20

    # Split parameters for parallel processing
    param_combinations = [(max_m, max_n, max_s, max_t)]

    # Number of processes to use
    num_processes = 4

    with Pool(num_processes) as pool:
        results = pool.map(calculate_roman_bounds, param_combinations)

    # Combine results from different processes
    roman_bounds = {}
    for result in results:
        roman_bounds.update(result)

    # Write Roman's bound values to zar.txt file
    with open('zar.txt', 'w') as f:
        #f.write('param Z{(m,n,s,t) in 1..20 cross 1..20 cross 1..20 cross 1..20};\n')
        for params, value in roman_bounds.items():
            # Replace round brackets with square brackets in the output tuple
            params_str = str(params).replace("(", "[").replace(")", "]")
            if value != 1000000000:  # Exclude Zarankiewicz number if it equals 1000000000
                f.write(f'param Z{params_str} := {value};\n')
