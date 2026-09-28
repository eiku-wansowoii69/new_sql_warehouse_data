# SQL Data Warehouse Project

基于 **SQL Server** 构建的企业级数据仓库项目，通过整合 CRM 与 ERP 多源业务数据，完成从原始数据接入、数据清洗与整合，到面向业务分析的数据集构建。

项目采用 **ODS → DWD → ADS** 的经典数仓分层架构，并使用 **Tableau** 对 ADS 层数据进行可视化分析。

---

## 📌 项目简介

本项目模拟企业实际数据仓库建设场景，将来自不同业务系统的 CRM 与 ERP 数据统一接入 SQL Server 数据仓库。

通过分层设计，将数据处理过程拆分为：

* **ODS（Operational Data Store）**：原始数据接入与落地
* **DWD（Data Warehouse Detail）**：明细数据清洗、标准化及多源数据整合
* **ADS（Application Data Service）**：面向具体业务分析需求的数据集

最终通过 Tableau 对 ADS 层数据进行可视化，分析客户、产品及销售等业务主题。

---

## 📂 项目目录结构

```text
new_sql_warehouse_data/
│
├── datasets/
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   │
│   └── source_erp/
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
│
├── docs/
│   ├── data_architecture/
│   ├── data_model/
│   └── data_flow/
│
├── scripts/
│   ├── ODS/
│   ├── DWD/
│   └── ADS/
│
├── tests/
│
├── BI/
│
└── README.md
```

---

## 🛠️ 技术栈

| Technology       | Purpose           |
| ---------------- | ----------------- |
| **SQL Server**   | 数据仓库建设与数据存储       |
| **T-SQL**        | 数据清洗、转换、关联及数据处理   |
| **Tableau**      | BI 可视化与 Dashboard |
| **Git / GitHub** | 项目版本管理与代码托管       |

---

## 🏗️ 项目架构

本项目采用 **ODS → DWD → ADS** 三层数据仓库架构。

```text
┌──────────────────────────────┐
│        Source Systems        │
│                              │
│   CRM                ERP     │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│             ODS              │
│     原始数据接入与存储层       │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│             DWD              │
│   数据清洗 / 标准化 / 数据整合 │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│             ADS              │
│      面向业务分析的数据层      │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│           Tableau             │
│        BI Visualization       │
└──────────────────────────────┘
```

---

# 🔄 Data Warehouse Layers

## 1. ODS Layer

**ODS（Operational Data Store）** 主要负责源系统数据的接入和落地。

项目中的数据主要来自两个业务系统：

### CRM

```text
cust_info.csv
prd_info.csv
sales_details.csv
```

主要包含：

* 客户信息
* 产品信息
* 销售明细

### ERP

```text
CUST_AZ12.csv
LOC_A101.csv
PX_CAT_G1V2.csv
```

主要包含：

* 客户补充信息
* 地区信息
* 产品分类信息

ODS 层尽量保留源系统数据的原始结构，为后续 DWD 层的数据处理提供完整的数据来源。

---

## 2. DWD Layer

**DWD（Data Warehouse Detail）** 是本项目的核心数据处理层。

在这一层对 ODS 中的原始数据进行清洗、标准化以及多源数据整合，将不同业务系统的数据转换成结构统一、质量更高的明细数据。

主要处理内容包括：

### 数据清洗

* 去除字符串首尾空格
* 处理空值
* 处理重复数据
* 检查无效业务数据
* 检查异常日期
* 处理不符合业务规则的数据

### 数据标准化

对不同来源系统中相同业务含义的数据进行统一。

例如：

* 统一性别字段取值
* 统一日期格式
* 统一字段格式
* 标准化业务 ID
* 统一数据类型

### 多源数据整合

将 CRM 与 ERP 中属于同一业务主题的数据进行关联。

例如：

```text
CRM Customer
       +
ERP Customer
       ↓
DWD Customer
```

以及：

```text
CRM Product
       +
ERP Product Category
       ↓
DWD Product
```

通过 DWD 层完成不同来源数据的整合，为 ADS 层提供统一的数据基础。

---

# 3. ADS Layer

**ADS（Application Data Service）** 面向最终业务分析需求。

在 DWD 层完成数据清洗与整合之后，根据业务分析场景进一步组织数据，为 SQL 分析和 BI 可视化提供直接使用的数据集。

主要围绕以下业务主题：

### Customer

用于分析：

* 客户数量
* 客户属性
* 客户地区
* 客户销售贡献

### Product

用于分析：

* 产品销售表现
* 产品类别
* 产品销量
* 产品收入贡献

### Sales

用于分析：

* 销售收入
* 销售数量
* 销售趋势
* 产品销售表现
* 客户销售表现

ADS 层的数据经过业务整合后，可以直接提供给 Tableau 使用。

---

# 🧹 Data Cleaning & Transformation

本项目重点对多源业务数据进行了数据质量处理。

### 1. Missing Values

检查客户、产品及销售数据中的缺失值，并根据字段业务含义进行处理。

### 2. Duplicate Records

检查关键业务数据中的重复记录，避免重复数据影响后续统计分析。

### 3. Data Standardization

统一不同数据源中的字段格式和业务取值。

例如：

```text
Female
female
F
```

根据业务规则进行统一处理。

### 4. Invalid Data

检查业务数据中的异常记录，例如：

* 无效 ID
* 无法匹配的数据
* 异常日期
* 不符合业务规则的记录

### 5. Cross-System Integration

针对 CRM 与 ERP 中存在关联关系的数据进行匹配和整合，解决不同来源系统之间的数据差异。

---

# ⭐ Data Modeling

DWD 层在完成数据清洗和整合之后，根据业务关系组织明细数据。

ADS 层则根据实际业务分析需求构建面向分析的数据结构。

核心业务实体包括：

```text
Customer
    │
    │
    ▼
Sales
    ▲
    │
    │
Product
```

其中：

* **Customer**：描述客户相关属性
* **Product**：描述产品及产品分类信息
* **Sales**：记录销售业务明细

这种设计能够将业务描述信息与销售交易信息进行关联，方便后续从客户、产品等不同维度进行分析。

---

# 📊 BI看板

项目使用 **Tableau** 对 ADS 层数据进行可视化分析。

Dashboard 主要围绕以下业务方向展开：

![demo](BI/销售看板.png)


---

# 📚 数据来源

本项目使用 CRM 和 ERP 两个业务系统提供的 CSV 数据作为原始数据源。

### CRM Source

| Dataset             | Description          |
| ------------------- | -------------------- |
| `cust_info.csv`     | Customer Information |
| `prd_info.csv`      | Product Information  |
| `sales_details.csv` | Sales Details        |

### ERP Source

| Dataset           | Description                  |
| ----------------- | ---------------------------- |
| `CUST_AZ12.csv`   | Customer Information         |
| `LOC_A101.csv`    | Location Information         |
| `PX_CAT_G1V2.csv` | Product Category Information |

原始数据经过 ODS 层接入后，在 DWD 层完成数据清洗、标准化及多源数据整合，最终形成 ADS 层分析数据。

---

## 📄 License

This project is licensed under the MIT License.
