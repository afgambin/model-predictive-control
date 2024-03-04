# Online Power Management Strategies for Energy Harvesting Mobile Networks

The design of self-sustainable Base Station (BS) deployments is addressed in this project. 

We target deployments featuring small BSs with Energy Harvesting (EH) and storage capabilities. These BSs can use ambient energy to serve the local traffic or store it for later use. A dedicated power packet grid is utilized to transfer energy across them, compensating for imbalance in the harvested energy or in the traffic load. Some BSs are offgrid, i.e., they can only use the locally harvested energy and that transferred from other BSs, whereas others are ongrid, i.e., they can additionally purchase energy from the power grid. 

Within this setup, an optimization problem is formulated where: harvested energy and traffic processes are estimated (at
runtime) at the BSs through Gaussian Processes (GPs), and a Model Predictive Control (MPC) framework is devised for the computation of energy allocation and transfer across base stations. 

The combination of prediction and optimization tools leads to an efficient and online solution that automatically adapts to energy harvesting and load dynamics. Numerical results, obtained using real energy harvesting and traffic profiles, show substantial improvements with respect to the case where the optimization is carried out without predicting future system dynamics. The main improvements are in the outage probability (zero in most cases), and in the amount of energy purchased from the power grid, that is more than halved for the same served load.

This is the code repository of the project. You can find more information about it here: https://ieeexplore.ieee.org/document/8661519