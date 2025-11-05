open Unix

(* ---------- Portfolio Type ---------- *)
type portfolio = {
  weights : float list;
  cov_matrix : float array array;
  trans_costs : float list;
  exposures : float list;
}

(* ---------- Utility Functions ---------- *)

(* Matrix-vector multiplication: Σw *)
let mat_vec_mul mat vec =
  Array.map (fun row ->
    Array.mapi (fun i x -> x *. vec.(i)) row
    |> Array.fold_left (+.) 0.0
  ) mat

(* Vector dot product: wᵀΣw *)
let dot_product arr1 arr2 =
  Array.mapi (fun i x -> x *. arr2.(i)) arr1
  |> Array.fold_left (+.) 0.0

(* Quadratic form wᵀΣw *)
let quadratic_form weights cov =
  let w_arr = Array.of_list weights in
  let sigma_w = mat_vec_mul cov w_arr in
  dot_product w_arr sigma_w

let portfolio_variance weights cov =
  quadratic_form weights cov

(* Value-at-Risk *)
let value_at_risk weights cov z =
  let var = portfolio_variance weights cov in
  z *. sqrt var

(* Transaction cost penalty *)
let transaction_penalty weights costs =
  List.map2 (fun w c -> abs_float w *. c) weights costs
  |> List.fold_left (+.) 0.0

(* Exposure penalty *)
let exposure_penalty exposures =
  List.map abs_float exposures |> List.fold_left (+.) 0.0

(* ---------- Latency Timing ---------- *)

(* Measure execution time of a function *)
let time_function f x =
  let start_time = gettimeofday () in
  let result = f x in
  let end_time = gettimeofday () in
  let latency = end_time -. start_time in
  (result, latency)

(* Latency penalty (penalise long computation times) *)
let latency_penalty latency =
  if latency > 0.01 then latency *. 1000.0  (* 10 ms threshold *)
  else 0.0

(* ---------- Spot Check Consistency ---------- *)

type spot_data = {
  source : string;
  pair : string;
  price : float;
}

(* Check if all data sources report consistent spot prices within tolerance *)
let spot_check_consistency data_list tolerance =
  let avg_price =
    List.fold_left (fun acc d -> acc +. d.price) 0.0 data_list /. float_of_int (List.length data_list)
  in
  let deviations =
    List.map (fun d -> abs_float (d.price -. avg_price)) data_list
  in
  List.for_all (fun dev -> dev <= tolerance) deviations

(* ---------- Adjusted Markowitz Objective ---------- *)

let adjusted_objective_with_latency portfolio z lambda1 lambda2 lambda3 =
  let (var_term, latency) = time_function (fun () ->
    value_at_risk portfolio.weights portfolio.cov_matrix z
  ) () in
  let cost_term = transaction_penalty portfolio.weights portfolio.trans_costs in
  let exp_term = exposure_penalty portfolio.exposures in
  let latency_term = latency_penalty latency in
  var_term +. lambda1 *. cost_term +. lambda2 *. exp_term +. lambda3 *. latency_term

(* ---------- Example Run ---------- *)

let () =
  let portfolio_example = {
    weights = [0.4; 0.3; 0.3];
    cov_matrix = [|
      [|0.04; 0.01; 0.02|];
      [|0.01; 0.03; 0.015|];
      [|0.02; 0.015; 0.05|];
    |];
    trans_costs = [0.001; 0.002; 0.0015];
    exposures = [0.1; -0.05; 0.08];
  } in

  (* Spot check data for EUR/USD *)
  let spot_sources = [
    {source="Bloomberg"; pair="EUR/USD"; price=1.1025};
    {source="Reuters"; pair="EUR/USD"; price=1.1026};
    {source="ExchangeAPI"; pair="EUR/USD"; price=1.1024};
  ] in

  (* Verify spot price consistency before proceeding *)
  let consistent = spot_check_consistency spot_sources 0.0003 in

  let z = 1.65 in
  let lambda1 = 10.0 in
  let lambda2 = 5.0 in
  let lambda3 = 0.5 in

  if consistent then begin
    let obj_value = adjusted_objective_with_latency portfolio_example z lambda1 lambda2 lambda3 in
    Printf.printf "Spot check passed ✅\n";
    Printf.printf "Adjusted Markowitz Objective: %f\n" obj_value
  end else
    Printf.printf "Spot check failed ⚠️: inconsistent market data.\n"

