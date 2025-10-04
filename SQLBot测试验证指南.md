# SQLBot 测试验证指南

**日期**：2025-10-04  
**目的**：验证使用官方 DatasetSQLBotServer.java 后的功能

---

## 📋 测试概述

由于我们删除了 `DataAssistantServer.java`，恢复了官方的 `DatasetSQLBotServer.java`，需要重新编译和测试以确保功能正常。

---

## 🔍 当前状态

### 代码文件

- ❌ `DataAssistantServer.java` - 已删除
- ✅ `DatasetSQLBotServer.java` - 已恢复（官方文件）

### 服务状态

- ⏸️ weisoftBI 服务：未运行
- ✅ SQLBot 服务：运行中（Docker）

---

## 🚀 测试步骤

### 步骤 1：重新编译代码

#### 方法 A：只编译后端（推荐，快速）

```bash
cd core/core-backend
mvn clean compile -DskipTests
```

**预期结果**：
```
[INFO] BUILD SUCCESS
[INFO] Total time: XX s
```

---

#### 方法 B：完整编译（包含打包）

```bash
cd core/core-backend
mvn clean package -DskipTests
```

**预期结果**：
```
[INFO] BUILD SUCCESS
[INFO] Total time: XX s
```

---

### 步骤 2：启动 weisoftBI 服务

#### 方法 A：使用 Maven 启动（开发模式）

```bash
cd /Users/wei.lb/Documents/wps2024/weisoft/weisoftBI/weisoftbi

./mvnw spring-boot:run -pl core/core-backend \
  -Dspring-boot.run.profiles=dev \
  -Dspring-boot.run.jvmArguments="-Xmx2g"
```

**预期输出**：
```
Started DataEaseApplication in XX seconds
```

---

#### 方法 B：使用 JAR 启动（生产模式）

```bash
cd core/core-backend/target

java -jar dataease-backend-*.jar \
  --spring.profiles.active=dev \
  -Xmx2g
```

---

### 步骤 3：验证服务启动

#### 检查端口

```bash
lsof -i :8100 | grep LISTEN
```

**预期输出**：
```
java    XXXXX wei.lb   XXu  IPv6 XXXXXXXXXX      0t0  TCP *:xprint-server (LISTEN)
```

---

#### 检查日志

查看启动日志，确认没有错误：

```bash
# 如果使用 Maven 启动，日志会直接显示在终端

# 如果使用 JAR 启动，查看日志文件
tail -f logs/dataease.log
```

**关键日志**：
```
Started DataEaseApplication in XX seconds
Tomcat started on port(s): 8100 (http)
```

---

### 步骤 4：测试 REST API

#### 测试 1：基本连接测试

```bash
curl -I http://192.168.3.232:8100/de2api/sqlbot/datasource
```

**预期结果**：
```
HTTP/1.1 401 Unauthorized
```

**说明**：返回 401 是正常的，说明接口存在但需要认证。

---

#### 测试 2：带认证的 API 测试

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
      "tables": [
        {
          "name": "表名",
          "comment": "表描述",
          "columns": [...]
        }
      ]
    }
  ]
}
```

**说明**：
- `code: 0` 表示成功
- `data` 包含数据源列表
- 每个数据源包含表和列信息

---

#### 测试 3：使用 jq 格式化输出

```bash
curl -s -H "x-de-token: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1aWQiOjEsIm9pZCI6MX0.UK4jQ8CzyC8nylz_eAFZMa8agK9vCF2zt9GQENwXbV0" \
  http://192.168.3.232:8100/de2api/sqlbot/datasource | jq .
```

---

### 步骤 5：测试 SQLBot 功能

#### 5.1 访问 SQLBot 界面

在浏览器中访问：
```
http://192.168.3.232:8100/#/sqlbot/index
```

**预期结果**：
- ✅ 页面正常加载
- ✅ 没有 JavaScript 错误
- ✅ 可以看到输入框

---

#### 5.2 测试问答功能

**测试问题 1**：
```
查询模块活跃数据
```

**预期结果**：
- ✅ SQLBot 能够识别数据源
- ✅ 生成 SQL 查询
- ✅ 返回查询结果

---

**测试问题 2**：
```
统计每个模块的活跃人数
```

**预期结果**：
- ✅ 生成带有 GROUP BY 的 SQL
- ✅ 返回统计结果

---

**测试问题 3**：
```
显示最近 30 天的资金流入
```

**预期结果**：
- ✅ 生成带有日期过滤的 SQL
- ✅ 返回时间范围内的数据

---

### 步骤 6：检查日志

#### weisoftBI 日志

查看是否有错误：

```bash
# 如果使用 Maven 启动，查看终端输出

# 如果使用 JAR 启动
tail -f logs/dataease.log | grep -i "error\|exception"
```

**预期结果**：没有错误日志

---

#### SQLBot 日志

```bash
docker logs sqlbot --tail 50
```

**关键日志**：
```
INFO: 成功获取数据源列表
INFO: 生成 SQL 查询
INFO: 执行查询成功
```

---

## ✅ 验证清单

### 编译和启动

- [ ] 代码编译成功
- [ ] 服务启动成功
- [ ] 端口 8100 正常监听
- [ ] 没有启动错误

### API 测试

- [ ] 基本连接测试通过（返回 401）
- [ ] 带认证的 API 测试通过（返回数据）
- [ ] 返回的数据格式正确
- [ ] 包含数据源和表信息

### SQLBot 功能测试

- [ ] SQLBot 界面正常加载
- [ ] 可以输入问题
- [ ] 能够识别数据源
- [ ] 生成 SQL 查询
- [ ] 返回查询结果
- [ ] 没有错误提示

### 日志检查

- [ ] weisoftBI 日志没有错误
- [ ] SQLBot 日志没有错误
- [ ] 没有 401 或 404 错误

---

## 🐛 常见问题

### 问题 1：编译失败

**现象**：
```
[ERROR] Failed to execute goal
```

**解决**：
```bash
# 清理缓存
mvn clean

# 重新编译
mvn compile -DskipTests
```

---

### 问题 2：端口被占用

**现象**：
```
Port 8100 is already in use
```

**解决**：
```bash
# 查找占用端口的进程
lsof -i :8100

# 杀死进程
kill -9 <PID>
```

---

### 问题 3：API 返回 404

**现象**：
```
HTTP/1.1 404 Not Found
```

**原因**：
- 代码没有重新编译
- 服务没有重启

**解决**：
1. 重新编译代码
2. 重启服务

---

### 问题 4：API 返回 401

**现象**：
```
HTTP/1.1 401 Unauthorized
```

**原因**：
- Token 过期
- Token 不正确

**解决**：
1. 登录 weisoftBI
2. 在浏览器控制台获取新 Token：
   ```javascript
   JSON.parse(localStorage.getItem('user')).v
   ```
3. 使用新 Token 测试

---

### 问题 5：SQLBot 无法获取数据源

**现象**：
```
没有找到匹配的数据源
```

**原因**：
- 数据源描述不够详细
- SQLBot 配置不正确

**解决**：
1. 检查数据源描述
2. 检查 SQLBot 数据库配置
3. 重启 SQLBot：`docker restart sqlbot`

---

## 📊 测试结果记录

### 测试环境

- **操作系统**：macOS
- **Java 版本**：Java 21
- **Maven 版本**：3.x
- **weisoftBI 版本**：基于 DataEase 定制
- **SQLBot 版本**：Docker 容器

### 测试结果

| 测试项 | 状态 | 备注 |
|--------|------|------|
| 代码编译 | ⏳ 待测试 | |
| 服务启动 | ⏳ 待测试 | |
| API 测试 | ⏳ 待测试 | |
| SQLBot 功能 | ⏳ 待测试 | |
| 日志检查 | ⏳ 待测试 | |

---

## 🎯 总结

### 为什么需要重新编译？

1. **类名变更**：从 `DataAssistantServer` 改为 `DatasetSQLBotServer`
2. **确保使用官方代码**：重新编译可以确保使用的是官方文件
3. **避免缓存问题**：清理旧的 class 文件

### 测试的重要性

1. **验证功能**：确保官方文件功能正常
2. **发现问题**：及时发现潜在问题
3. **建立信心**：确认集成成功

---

## 🚀 快速测试命令

```bash
# 1. 重新编译
cd /Users/wei.lb/Documents/wps2024/weisoft/weisoftBI/weisoftbi/core/core-backend
mvn clean compile -DskipTests

# 2. 启动服务
cd /Users/wei.lb/Documents/wps2024/weisoft/weisoftBI/weisoftbi
./mvnw spring-boot:run -pl core/core-backend -Dspring-boot.run.profiles=dev

# 3. 测试 API（在新终端）
curl -H "x-de-token: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1aWQiOjEsIm9pZCI6MX0.UK4jQ8CzyC8nylz_eAFZMa8agK9vCF2zt9GQENwXbV0" \
  http://192.168.3.232:8100/de2api/sqlbot/datasource | jq .

# 4. 测试 SQLBot
# 在浏览器中访问：http://192.168.3.232:8100/#/sqlbot/index
```

---

**准备好了吗？开始测试吧！** 🚀

