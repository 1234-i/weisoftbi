-- 更新 weisoftBI 数据源描述，以便 SQLBot AI 模型能够更准确地匹配数据源

-- 更新 Demo 数据源的描述
UPDATE core_datasource 
SET `desc` = '包含茶饮相关的订单和原料数据，适用于茶饮店铺的销售分析和成本管理。包含茶饮订单明细表和茶饮原料费用表。'
WHERE name = 'Demo';

-- 更新 开发机器本地数据 数据源的描述
UPDATE core_datasource 
SET `desc` = '包含财务模块活跃数据和月度资金流入数据，适用于财务分析和资金流向追踪。包含模块活跃数据表(financial_module_active)和月度资金流入表(financial_monthly_inflow)。'
WHERE name = '开发机器本地数据';

-- 查看更新后的结果
SELECT id, name, `desc` FROM core_datasource WHERE name IN ('Demo', '开发机器本地数据');

