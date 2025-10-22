# 🌍 GreenEarth Fund

A decentralized environmental funding platform that connects eco-conscious investors with impactful green projects. Fund renewable energy, reforestation, clean water, and other sustainability initiatives while tracking real environmental impact on the blockchain.

## 🌱 Features

- **🌿 Project Categories**: 6 predefined environmental categories
- **💰 Crowdfunding**: Community-driven funding for green projects
- **🎯 Milestone Tracking**: Track project progress with verifiable milestones
- **🔍 Impact Verification**: Third-party verification of environmental impact
- **📊 Carbon Offset Tracking**: Monitor and track carbon offset achievements
- **⏰ Deadline Management**: Time-bound funding with automatic refunds
- **🛡️ Platform Security**: Smart contract-based fund management
- **📈 Impact Scoring**: Quantitative measurement of environmental impact

## 🌍 Environmental Categories

1. **⚡ Renewable Energy** - Solar, wind, hydro power projects
2. **🌳 Reforestation** - Tree planting and forest restoration
3. **💧 Clean Water** - Water purification and access projects  
4. **♻️ Waste Management** - Recycling and waste reduction initiatives
5. **🦎 Wildlife Conservation** - Habitat protection and species preservation
6. **🚜 Sustainable Agriculture** - Eco-friendly farming practices

## 🔧 Contract Functions

### Project Management

#### `initialize-categories`
Initialize the 6 environmental project categories.
```clarity
(initialize-categories)
```

#### `create-project`
Create a new environmental project.
```clarity
(create-project title description category funding-goal deadline carbon-offset)
```
- **title**: Project name (max 256 chars)
- **description**: Detailed project description (max 512 chars)
- **category**: Environmental category (1-6)
- **funding-goal**: Target funding amount (10,000-100,000,000 µSTX)
- **deadline**: Project deadline (block height)
- **carbon-offset**: Expected carbon offset in tons

#### `fund-project`
Contribute funding to an environmental project.
```clarity
(fund-project project-id amount)
```
- **project-id**: ID of project to fund
- **amount**: Funding amount in µSTX
- Platform fee: 3% deducted for sustainability

#### `withdraw-funds`
Withdraw funded amount (project creator only).
```clarity
(withdraw-funds project-id)
```

#### `refund-expired-project`
Get refund for unfunded expired projects.
```clarity
(refund-expired-project project-id)
```

### Milestone & Impact Tracking

#### `create-milestone`
Create project milestone (project creator only).
```clarity
(create-milestone project-id title target-amount impact-data)
```
- **target-amount**: Milestone funding target
- **impact-data**: Environmental impact description

#### `verify-milestone`
Verify milestone completion (authorized verifiers only).
```clarity
(verify-milestone milestone-id)
```
- Increases project impact score
- Updates carbon offset tracking

#### `add-verifier`
Add authorized impact verifier (admin only).
```clarity
(add-verifier verifier)
```

### Query Functions

#### `get-project`
Retrieve project details and funding status.

#### `get-platform-stats`
Get comprehensive platform statistics.

#### `get-active-projects`
List all currently active projects.

#### `get-project-milestones`
Get all milestones for a specific project.

#### `get-funder-projects`
Get all projects funded by a specific user.

### Admin Functions

#### `deactivate-project`
Deactivate a project (creator only).

#### `withdraw-treasury`
Withdraw platform fees (admin only).

## 🛠️ Usage Examples

### Initialize Platform Categories
```bash
clarinet console
(contract-call? .green-fund initialize-categories)
```

### Create a Renewable Energy Project
```bash
(contract-call? .green-fund create-project 
  "Solar Farm Initiative"
  "Building a 100MW solar farm to power 50,000 homes with clean energy"
  u1
  u1000000
  u150000
  u500)
```

### Fund a Project
```bash
;; Fund with 50,000 µSTX
(contract-call? .green-fund fund-project u1 u50000)
```

### Create Project Milestone
```bash
(contract-call? .green-fund create-milestone 
  u1
  "Phase 1: Land Acquisition Complete"
  u200000
  "Secured 500 acres of optimal solar land")
```

### Check Platform Statistics
```bash
(contract-call? .green-fund get-platform-stats)
```

### Get Active Projects
```bash
(contract-call? .green-fund get-active-projects)
```

## 🔧 Development Setup

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet)
- Node.js (for testing)

### Installation
```bash
git clone <repository>
cd GreenEarth-Fund
clarinet check
```

### Testing
```bash
npm install
npm test
```

## 📖 Contract Details

- **Contract Name**: `green-fund`
- **Network**: Stacks Blockchain
- **Language**: Clarity
- **Lines of Code**: 413
- **Min Funding Goal**: 10,000 µSTX
- **Max Funding Goal**: 100,000,000 µSTX
- **Platform Fee**: 3% (30/1000)
- **Impact Multiplier**: 100x for scoring

## 🛡️ Security Features

- ✅ Funding goal validation (10K-100M µSTX range)
- ✅ Deadline enforcement with automatic expiry
- ✅ Creator-only project management
- ✅ Verifier authorization system
- ✅ Platform fee collection for sustainability
- ✅ Refund protection for failed projects
- ✅ Overflow protection in all calculations

## 💰 Economics & Sustainability

### Funding Flow
1. **Contributors** fund projects with STX tokens
2. **Platform Fee** (3%) supports development and verification
3. **Project Creators** receive 97% of contributions
4. **Failed Projects** get automatic refunds after deadline

### Impact Measurement
- **Carbon Offset Tracking**: Cumulative environmental impact
- **Impact Scoring**: Quantitative project effectiveness
- **Milestone Verification**: Third-party validation
- **Transparent Reporting**: On-chain impact data

## 🌍 Environmental Impact

### Measurable Outcomes
- **Carbon Reduction**: Track CO2 offset in tons
- **Energy Generation**: Renewable energy capacity
- **Reforestation**: Trees planted and area restored
- **Water Access**: People served with clean water
- **Waste Reduction**: Materials recycled and diverted

### Verification Process
1. **Project Milestones**: Creator sets measurable goals
2. **Third-party Verification**: Authorized verifiers validate
3. **Impact Scoring**: Automatic calculation of environmental benefit
4. **Blockchain Recording**: Immutable impact tracking

## 📊 Platform Analytics

Track comprehensive metrics:
- Total environmental projects funded
- Cumulative carbon offset achieved
- Geographic distribution of projects
- Category-wise funding allocation
- Verifier performance statistics
- Community impact measurements

## 🌟 Project Success Stories

### Renewable Energy
- Solar farms generating clean electricity
- Wind turbines reducing fossil fuel dependency
- Hydro projects powering remote communities

### Reforestation
- Million-tree planting initiatives
- Rainforest conservation programs
- Urban reforestation projects

### Clean Water
- Well drilling in underserved areas
- Water purification system installations
- Ocean cleanup initiatives

## 🚀 Future Enhancements

- **🌐 Global Expansion**: Multi-language support
- **📱 Mobile App**: User-friendly project discovery
- **🔗 IoT Integration**: Real-time impact monitoring
- **🏆 Rewards System**: NFT certificates for supporters
- **📊 Advanced Analytics**: AI-powered impact prediction
- **🤝 Partnership Programs**: Corporate sustainability integration

## 🎯 Impact Goals

### 2024 Targets
- Fund 100+ environmental projects
- Offset 10,000 tons of CO2
- Generate 50MW of renewable energy
- Plant 100,000 trees globally

### Long-term Vision
- Become the leading blockchain environmental funding platform
- Enable transparent, verifiable sustainability investments
- Create a global network of verified environmental projects
- Drive measurable positive environmental change

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `clarinet check`
5. Submit a pull request

## 📄 License

This project is open source. See LICENSE file for details.

## 🆘 Support

For questions or issues:
- Create an issue on GitHub
- Join our community discussions
- Check the documentation

---

*Building a sustainable future through decentralized environmental funding* 🌱💚
