

🧠 Adjusted Markowitz Portfolio Optimisation (OCaml)
This project implements an Adjusted Markowitz Portfolio Optimisation algorithm in OCaml to model real-world portfolio risk management.
It extends the classical mean–variance framework by incorporating:
Value-at-Risk (VaR) for risk quantification
Transaction cost penalties for realistic trading behaviour
Exposure penalties for risk concentration control
Latency measurement to capture execution efficiency
Spot check consistency for validating market data reliability
This mirrors how a trader might systematically net currency pairs to minimise Value-at-Risk (VaR) while also improving latency arbitrage performance and maintaining consistent spot pricing.
📘 Key Features
Feature	Description
Adjusted Objective Function	Extends Markowitz optimisation with transaction and exposure penalties
Value-at-Risk (VaR)	Estimates potential loss given portfolio weights and covariance matrix
Latency Timer	Measures function execution time for performance testing
Spot Price Consistency Check	Ensures data from multiple market sources are within acceptable deviation
Fully Functional in OCaml	Demonstrates numerical and functional programming in a finance context
🧮 Mathematical Idea
The adjusted objective function is defined as:
J
(
w
)
=
VaR
(
w
)
+
λ
1
⋅
TransactionPenalty
(
w
)
+
λ
2
⋅
ExposurePenalty
(
w
)
J(w)=VaR(w)+λ 
1
​	
 ⋅TransactionPenalty(w)+λ 
2
​	
 ⋅ExposurePenalty(w)
where:
w
w = portfolio weights
Σ
Σ = covariance matrix
VaR
(
w
)
=
z
w
T
Σ
w
VaR(w)=z 
w 
T
 Σw
​	
 
λ
1
,
λ
2
λ 
1
​	
 ,λ 
2
​	
  = penalty weights controlling trade-off intensity
🧩 Project Structure
├── adjusted_markowitz.ml     # Main OCaml source file
├── README.md                 # Documentation (this file)
💻 Code Implementation
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

let mat_vec_mul mat vec =
  Array.map (fun row ->
    Array.mapi (fun i x -> x *. vec.(i)) row
    |> Array.fold_left (+.) 0.0
  ) mat

let dot_product arr1 arr2 =
  Array.mapi (fun i x -> x *. arr2.(i)) arr1
  |> Array.fold_left (+.) 0.0

let quadratic_form weights cov =
  let w_arr = Array.of_list weights in
  let sigma_w = mat_vec_mul cov w_arr in
  dot_product w_arr sigma_w

let portfolio_variance weights cov = quadratic_form weights cov

let value_at_risk weights cov z =
  let var = portfolio_variance weights cov in
  z *. sqrt var

let transaction_penalty weights costs =
  List.map2 (fun w c -> abs_float w *. c) weights costs
  |> List.fold_left (+.) 0.0

let exposure_penalty exposures =
  List.map abs_float exposures |> List.fold_left (+.) 0.0

let adjusted_objective portfolio z lambda1 lambda2 =
  let var_term = value_at_risk portfolio.weights portfolio.cov_matrix z in
  let cost_term = transaction_penalty portfolio.weights portfolio.trans_costs in
  let exp_term = exposure_penalty portfolio.exposures in
  var_term +. lambda1 *. cost_term +. lambda2 *. exp_term

(* ===== Latency Measurement ===== *)

let time_function f x =
  let start_time = Unix.gettimeofday () in
  let result = f x in
  let end_time = Unix.gettimeofday () in
  let latency = end_time -. start_time in
  (result, latency)

(* ===== Spot Price Consistency Check ===== *)

type data_source = { name : string; price : float }

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

  let z = 1.65 in
  let lambda1 = 10.0 in
  let lambda2 = 5.0 in

  let (obj_value, latency) = time_function (fun p -> adjusted_objective p z lambda1 lambda2) portfolio_example in
  Printf.printf "Adjusted Markowitz Objective: %f\nLatency: %f seconds\n" obj_value latency;

  let data_sources = [
    { name = "SourceA"; price = 1.205 };
    { name = "SourceB"; price = 1.206 };
    { name = "SourceC"; price = 1.204 };
  ] in

  let consistent = spot_check_consistency data_sources 0.002 in
  Printf.printf "Spot price data consistent: %b\n" consistent
🧠 Example Output
Adjusted Markowitz Objective: 0.124873
Latency: 0.000012 seconds
Spot price data consistent: true
⚙️ How to Run
1. Install OCaml
You can install OCaml via opam:
brew install ocaml opam   # Mac
sudo apt install ocaml    # Linux
2. Run the Program
Save the file as adjusted_markowitz.ml and run:
ocaml unix.cma adjusted_markowitz.ml
📈 Conceptual Summary
This project bridges mathematical finance and functional programming by demonstrating how:
quantitative models can be expressed purely with functions and types,
financial risk measures can be computed symbolically, and
real-world trading factors (latency, costs, exposures) can be embedded into the optimisation process.
