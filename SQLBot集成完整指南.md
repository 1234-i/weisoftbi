# SQLBot 集成完整指南

**项目**：weisoftBI + SQLBot 集成  
**日期**：2025-10-04  
**状态**：✅ 集成成功

---

## 📋 目录

1. [概述](#概述)
2. [代码修改](#代码修改)
3. [配置修改](#配置修改)
4. [问题解决](#问题解决)
5. [测试验证](#测试验证)
6. [最佳实践](#最佳实践)

---

## 概述

### 集成目标

将 SQLBot（Text-to-SQL 系统）集成到 weisoftBI（DataEase 定制版）中，实现自然语言查询数据库功能。

### 集成结果

✅ **零代码修改** - 使用官方的 `DatasetSQLBotServer.java` 文件，无需修改任何代码

### 架构说明

- **weisoftBI**：运行在 `192.168.3.232:8100`
- **SQLBot**：运行在 Docker 容器，端口 `192.168.3.232:8000`
- **认证方式**：JWT Token（X-DE-TOKEN header）

---

## 代码修改

### ✅ 零代码修改！

本次集成使用官方的 `DatasetSQLBotServer.java` 文件，无需修改任何代码。

**官方文件位置**：
```
core/core-backend/src/main/java/io/dataease/dataset/server/DatasetSQLBotServer.java
```

**文件内容**：
```java
package io.dataease.dataset.server;

import io.dataease.api.dataset.DataAssistantApi;
import io.dataease.api.dataset.vo.DataSQLBotAssistantVO;
import io.dataease.dataset.manage.DatasetSQLBotManage;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/sqlbot")
public class DatasetSQLBotServer implements DataAssistantApi {

    @Resource
    private DatasetSQLBotManage datasetSQLBotManage;
    
    @Override
    public List<DataSQLBotAssistantVO> getDatasourceList(Long dsId, Long datasetId) {
        return datasetSQLBotManage.getDatasourceList(dsId, datasetId);
    }
}
```

**功能说明**：
- 提供 `/de2api/sqlbot/datasource` 接口
- 返回数据源列表供 SQLBot 调用
- 需要 X-DE-TOKEN 认证
- 返回的 List 会被 ResultResponseBodyAdvice 自动包装成 ResultMessage 格式

---

## 配置修改

### 1. SQLBot 数据库配置

**表**：`sys_assistant`  
**记录 ID**：7379744630536933376

#### 修改 domain

```sql
UPDATE sys_assistant 
SET domain = 'http://192.168.3.232:8100' 
WHERE id = 7379744630536933376;
```

**说明**：将 `localhost` 改为实际 IP 地址

#### 修改 certificate

```sql
UPDATE sys_assistant 
SET certificate = '[{"target": "header", "key": "x-de-token", "value": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1aWQiOjEsIm9pZCI6MX0.UK4jQ8CzyC8nylz_eAFZMa8agK9vCF2zt9GQENwXbV0"}]'
WHERE id = 7379744630536933376;
```

**说明**：存储实际的 JWT token，而不是 JavaScript 表达式

---

### 2. weisoftBI 数据源配置

#### Demo 数据源

**修改项**：
- **host**：`localhost` → `192.168.3.232`
- **description**：
  ```
  包含茶饮相关的订单和原料数据，适用于茶饮店铺的销售分析和成本管理。
  包含茶饮订单明细表和茶饮原料费用表。
  ```

#### 开发机器本地数据

**修改项**：
- **host**：`localhost` → `192.168.3.232`
- **description**：
  ```
  包含财务模块活跃数据和月度资金流入数据，适用于财务分析和资金流向追踪。
  包含模块活跃数据表(financial_module_active)和月度资金流入表(financial_monthly_inflow)。
  ```

**修改方式**：通过 weisoftBI Web 界面修改

---

## 问题解决

### 问题 1：认证白名单问题 ✅

**现象**：401 Unauthorized

**原因**：最初将 `/sqlbot/datasource` 加入白名单，导致无法获取用户上下文

**解决**：从白名单中移除，SQLBot 必须传递 X-DE-TOKEN

---

### 问题 2：域名校验失败 ✅

**现象**：域名校验失败【http://localhost:8100】

**原因**：SQLBot 数据库中配置的 domain 不正确

**解决**：更新为 `http://192.168.3.232:8100`

---

### 问题 3：401 Unauthorized 错误 ✅

**现象**：SQLBot 后端调用 API 时返回 401

**原因**：SQLBot 前端没有发送 certificate header

**解决**：将实际的 JWT token 存储在 certificate 字段中

---

### 问题 4：数据源匹配失败 ✅

**现象**：没有找到匹配的数据源

**原因**：数据源描述太简单，AI 模型无法匹配

**解决**：更新数据源描述，添加详细信息和关键词

---

### 问题 5：数据源无效 ✅

**现象**：数据源无效，无法连接到 MySQL

**原因**：数据源配置中 host 是 localhost，Docker 容器无法访问

**解决**：将 host 改为 `192.168.3.232`

---

## 测试验证

### 1. API 测试

```bash
curl -H "x-de-token: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1aWQiOjEsIm9pZCI6MX0.UK4jQ8CzyC8nylz_eAFZMa8agK9vCF2zt9GQENwXbV0" \
  http://192.168.3.232:8100/de2api/sqlbot/datasource
```

**预期结果**：
```json
{
  "code": 0,
  "msg": null,
  "data": [
    {
      "id": "数据源ID",
      "name": "数据源名称",
      "comment": "数据源描述",
      "tables": [...]
    }
  ]
}
```

---

### 2. SQLBot 功能测试

**访问地址**：`http://192.168.3.232:8100/#/sqlbot/index`

**测试问题**：
- "查询模块活跃数据"
- "统计每个模块的活跃人数"
- "显示最近 30 天的资金流入"

**预期结果**：
- ✅ 不再出现 TypeError 错误
- ✅ SQLBot 能够正常获取数据源列表
- ✅ 能够生成 SQL 查询并返回结果

---

## 最佳实践

### 1. 数据源配置

- **host**：使用实际 IP 而不是 localhost
- **description**：添加详细描述，包含关键词
- **测试连接**：每次修改后都要测试连接

### 2. Docker 网络

- Docker 容器中的 `localhost` 指向容器自己
- 需要使用宿主机 IP 或 `host.docker.internal`

### 3. AI 模型匹配

- 数据源描述需要详细且包含关键词
- 描述应该包含表名、用途、适用场景

### 4. 认证机制

- SQLBot type=1 模式需要在 certificate 字段中存储实际的 token
- 前端不会执行 JavaScript 表达式

### 5. 代码修改原则

- **优先使用官方代码** - 减少维护成本
- **零修改最佳** - 避免合并冲突
- **详细记录** - 文档比代码更重要

---

## 附录

### A. 相关文件

| 文件 | 说明 |
|------|------|
| `DatasetSQLBotServer.java` | 官方 REST API 实现 |
| `DatasetSQLBotManage.java` | 数据源管理类 |
| `DataAssistantApi.java` | API 接口定义 |

### B. 相关命令

```bash
# 重启 SQLBot
docker restart sqlbot

# 查看 SQLBot 日志
docker logs sqlbot --tail 100

# 测试 API
curl -H "x-de-token: TOKEN" http://192.168.3.232:8100/de2api/sqlbot/datasource

# 查看数据库配置
docker exec sqlbot psql -U root -d sqlbot -c "SELECT * FROM sys_assistant WHERE id = 7379744630536933376;"
```

### C. 常见问题

**Q: 为什么不修改代码？**  
A: 官方代码已经完全满足需求，零修改可以避免后续合并冲突。

**Q: 为什么要修改 host 为 IP？**  
A: Docker 容器中的 localhost 指向容器自己，无法访问宿主机的 MySQL。

**Q: 为什么数据源描述很重要？**  
A: AI 模型需要根据描述来匹配用户的问题到正确的数据源。

**Q: 如何获取 JWT Token？**  
A: 登录 weisoftBI 后，在浏览器控制台执行 `localStorage.getItem('user')`。

---

## 总结

### 成功要素

1. ✅ 使用官方代码，零代码修改
2. ✅ 正确配置 Docker 网络
3. ✅ 详细的数据源描述
4. ✅ 正确的认证机制
5. ✅ 完整的测试验证

### 关键经验

1. 💡 优先使用官方代码
2. 💡 Docker 网络需要特别注意
3. 💡 AI 模型需要详细的上下文
4. 💡 详细的文档比代码更重要

---

**恭喜！SQLBot 集成已成功完成！** 🎉

**开始使用**：
- 访问：`http://192.168.3.232:8100/#/sqlbot/index`
- 输入问题，例如："查询模块活跃数据"
- 享受智能问数的便利！

