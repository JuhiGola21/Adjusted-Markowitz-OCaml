# Adjusted-Markowitz-OCaml

(* =============================== *)
(* Adjusted Markowitz Portfolio Optimisation *)
(* =============================== *)

type portfolio = {
  weights : float list;          (* Portfolio weights *)
  cov_matrix : float array array;(* Covariance matrix of asset returns *)
  trans_costs : float list;      (* Transaction costs per asset *)
  exposures : float list;        (* Net exposure per asset *)
}

(* ===== Matrix and Math Operations ===== *)

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

(* Quadratic form: wᵀΣw *)
let quadratic_form weights cov =
  let w_arr = Array.of_list weights in
  let sigma_w = mat_vec_mul cov w_arr in
  dot_product w_arr sigma_w

(* Portfolio variance *)
let portfolio_variance weights cov =
  quadratic_form weights cov

(* Value at Risk (VaR) *)
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

(* ===== Adjusted Objective Function ===== *)

let adjusted_objective portfolio z lambda1 lambda2 =
  let var_term = value_at_risk portfolio.weights portfolio.cov_matrix z in
  let cost_term = transaction_penalty portfolio.weights portfolio.trans_costs in
  let exp_term = exposure_penalty portfolio.exposures in
  var_term +. lambda1 *. cost_term +. lambda2 *. exp_term

(* ===== Latency Measurement ===== *)

(* Measure execution time of a function *)
let time_function f x =
  let start_time = Unix.gettimeofday () in
  let result = f x in
  let end_time = Unix.gettimeofday () in
  let latency = end_time -. start_time in
  (result, latency)

(* ===== Spot Price Consistency Check ===== *)

type data_source = { name : string; price : float }

(* Check if all data sources report consistent spot prices within tolerance *)
let spot_check_consistency data_list tolerance =
  let avg_price =
    List.fold_left (fun acc d -> acc +. d.price) 0.0 data_list /. float_of_int (List.length data_list)
  in
  let deviations =
    List.map (fun d -> abs_float (d.price -. avg_price)) data_list
  in
  List.for_all (fun dev -> dev <= tolerance) deviations

(* ===== Example Usage ===== *)

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

  let z = 1.65 in          (* Confidence level for VaR *)
  let lambda1 = 10.0 in    (* Weight for transaction cost penalty *)
  let lambda2 = 5.0 in     (* Weight for exposure penalty *)

  (* Measure objective value and latency *)
  let (obj_value, latency) = time_function (fun p -> adjusted_objective p z lambda1 lambda2) portfolio_example in
  Printf.printf "Adjusted Markowitz Objective: %f\nLatency: %f seconds\n" obj_value latency;

  (* Example spot data from different sources *)
  let data_sources = [
    { name = "SourceA"; price = 1.205 };
    { name = "SourceB"; price = 1.206 };
    { name = "SourceC"; price = 1.204 };
  ] in

  let consistent = spot_check_consistency data_sources 0.002 in
  Printf.printf "Spot price data consistent: %b\n" consistent
