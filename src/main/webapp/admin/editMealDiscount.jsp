<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.math.BigDecimal" %>
<jsp:include page="/auth/AuthCheckAdmin.jsp" />

<%! 
    // safe decimal parse
    public BigDecimal parseDecimal(String s, BigDecimal def) {
        try {
            if (s == null || s.trim().isEmpty()) return def;
            return new BigDecimal(s.trim());
        } catch (Exception e) { 
            return def; 
        }
    }

    // safe DATE parse from yyyy-MM-dd
    public Date parseDate(String s) {
        try {
            if (s == null || s.trim().isEmpty()) return null;
            return Date.valueOf(s.trim()); // java.sql.Date
        } catch (Exception e) {
            return null;
        }
    }
%>

<%
/* ===============================
   1. DB CONFIG
================================*/
String connURL = "jdbc:mysql://localhost:3306/JAD_Assign1?user=root&password=password&serverTimezone=UTC";
Class.forName("com.mysql.cj.jdbc.Driver");

/* ===============================
   2. READ ACTION / PARAMS
================================*/
String action = request.getParameter("action");
if (action == null) action = "";

// form defaults
String formId = "";
String formName = "";
String formDesc = "";
String formType = "PERCENT_OFF";
String formValue = "0.00";
String formMinSpend = "0.00";
String formStart = "";
String formEnd = "";
String formActive = "1";

Connection conn = null;

try {
    conn = DriverManager.getConnection(connURL);

    /* ===============================
       3. DELETE
    ================================*/
    if ("delete".equals(action)) {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            PreparedStatement psDel =
                conn.prepareStatement("DELETE FROM meal_discount WHERE id=?");
            psDel.setInt(1, Integer.parseInt(idStr));
            psDel.executeUpdate();
            psDel.close();
        }
        response.sendRedirect(request.getContextPath() + "/admin/editMealDiscount.jsp");
        return;
    }

    /* ===============================
       4. SAVE (INSERT/UPDATE)
    ================================*/
    if ("save".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {

        String idStr = request.getParameter("id");
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String discountType = request.getParameter("discount_type");

        BigDecimal value = parseDecimal(request.getParameter("value"), BigDecimal.ZERO);
        BigDecimal minSpend = parseDecimal(request.getParameter("min_spend"), BigDecimal.ZERO);

        Date startDate = parseDate(request.getParameter("start_date"));
        Date endDate = parseDate(request.getParameter("end_date"));

        int isActive = "1".equals(request.getParameter("is_active")) ? 1 : 0;

        if (idStr == null || idStr.trim().isEmpty()) {
            // INSERT
            String insertSql = "INSERT INTO meal_discount " +
                    "(name, description, discount_type, value, min_spend, start_date, end_date, is_active) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement psIns = conn.prepareStatement(insertSql);
            psIns.setString(1, name);
            psIns.setString(2, description);
            psIns.setString(3, discountType);
            psIns.setBigDecimal(4, value);
            psIns.setBigDecimal(5, minSpend);

            if (startDate == null) psIns.setNull(6, Types.DATE);
            else psIns.setDate(6, startDate);

            if (endDate == null) psIns.setNull(7, Types.DATE);
            else psIns.setDate(7, endDate);

            psIns.setInt(8, isActive);

            psIns.executeUpdate();
            psIns.close();

        } else {
            // UPDATE
            String updateSql = "UPDATE meal_discount SET " +
                    "name=?, description=?, discount_type=?, value=?, min_spend=?, start_date=?, end_date=?, is_active=? " +
                    "WHERE id=?";
            PreparedStatement psUpd = conn.prepareStatement(updateSql);
            psUpd.setString(1, name);
            psUpd.setString(2, description);
            psUpd.setString(3, discountType);
            psUpd.setBigDecimal(4, value);
            psUpd.setBigDecimal(5, minSpend);

            if (startDate == null) psUpd.setNull(6, Types.DATE);
            else psUpd.setDate(6, startDate);

            if (endDate == null) psUpd.setNull(7, Types.DATE);
            else psUpd.setDate(7, endDate);

            psUpd.setInt(8, isActive);
            psUpd.setInt(9, Integer.parseInt(idStr));

            psUpd.executeUpdate();
            psUpd.close();
        }

        response.sendRedirect(request.getContextPath() + "/admin/editMealDiscount.jsp");
        return;
    }

    /* ===============================
       5. EDIT (LOAD INTO FORM)
    ================================*/
    if ("edit".equals(action)) {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            PreparedStatement psOne =
                conn.prepareStatement("SELECT * FROM meal_discount WHERE id=?");
            psOne.setInt(1, Integer.parseInt(idStr));
            ResultSet r1 = psOne.executeQuery();

            if (r1.next()) {
                formId = r1.getString("id");
                formName = r1.getString("name");
                formDesc = r1.getString("description");
                formType = r1.getString("discount_type");
                formValue = r1.getBigDecimal("value").toString();
                formMinSpend = r1.getBigDecimal("min_spend").toString();

                Date sd = r1.getDate("start_date");
                Date ed = r1.getDate("end_date");
                if (sd != null) formStart = sd.toString();  // yyyy-MM-dd
                if (ed != null) formEnd = ed.toString();

                formActive = r1.getInt("is_active") + "";
            }
            r1.close();
            psOne.close();
        }
    }

} catch (Exception e) {
    out.println("<p style='color:red'>Error: " + e.getMessage() + "</p>");
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Edit Meal Discounts</title>
<style>
  body { font-family: Arial, sans-serif; padding: 20px; }
  table { border-collapse: collapse; width: 100%; margin-top: 20px; }
  th, td { border: 1px solid #ddd; padding: 8px; vertical-align: top; }
  th { background: #f4f4f4; }
  .btn { padding: 6px 10px; border: 0; cursor: pointer; text-decoration:none; }
  .btn-edit { background:#4f46e5; color:white; }
  .btn-del { background:#dc2626; color:white; }
  .btn-save { background:#16a34a; color:white; }
  .btn-back { background:#64748b; color:white; }
  .card { border:1px solid #ddd; padding:16px; border-radius:12px; margin-bottom: 16px; }
  .row { display:flex; gap:12px; margin-bottom:10px; align-items:center; }
  .row label { width:170px; font-weight:bold; }
  input, select, textarea { padding:6px; width:280px; }
  textarea { height:70px; }
</style>
</head>
<body>

<h2>Meal Discount Rules (CRUD)</h2>

<a class="btn btn-back" href="<%=request.getContextPath()%>/admin/admin_homePage.jsp">
  ← Back to Admin Home
</a>

<div class="card">
  <h3><%= (formId.isEmpty() ? "Create New Meal Discount" : "Edit Meal Discount #" + formId) %></h3>

  <form method="post" action="<%=request.getContextPath()%>/admin/editMealDiscount.jsp?action=save">
    <input type="hidden" name="id" value="<%=formId%>" />

    <div class="row">
      <label>Name</label>
      <input type="text" name="name" required value="<%=formName%>" />
    </div>

    <div class="row">
      <label>Description</label>
      <textarea name="description"><%= formDesc == null ? "" : formDesc %></textarea>
    </div>

    <div class="row">
      <label>Discount Type</label>
      <select name="discount_type" required>
        <option value="PERCENT_OFF"  <%= "PERCENT_OFF".equals(formType) ? "selected" : "" %>>PERCENT_OFF</option>
        <option value="FLAT_OFF"     <%= "FLAT_OFF".equals(formType) ? "selected" : "" %>>FLAT_OFF</option>
        <option value="FREE_DELIVERY"<%= "FREE_DELIVERY".equals(formType) ? "selected" : "" %>>FREE_DELIVERY</option>
      </select>
    </div>

    <div class="row">
      <label>Value</label>
      <input type="number" step="0.1" name="value" value="<%=formValue%>" />
      <small>(5 = 5% for PERCENT_OFF, or $5 for FLAT_OFF)</small>
    </div>

    <div class="row">
      <label>Min Spend</label>
      <input type="number" step="0.1" name="min_spend" value="<%=formMinSpend%>" />
    </div>

    <div class="row">
      <label>Start Date</label>
      <input type="date" name="start_date" value="<%=formStart%>" required />
    </div>

    <div class="row">
      <label>End Date</label>
      <input type="date" name="end_date" value="<%=formEnd%>" />
      <small>(leave blank for no end)</small>
    </div>

    <div class="row">
      <label>Active?</label>
      <input type="checkbox" name="is_active" value="1"
        <%= "1".equals(formActive) ? "checked" : "" %> />
    </div>

    <button class="btn btn-save" type="submit">Save Discount</button>
    <a class="btn" href="<%=request.getContextPath()%>/admin/editMealDiscount.jsp">Clear Form</a>
  </form>
</div>

<%
/* ===============================
   6. LIST ALL DISCOUNTS
================================*/
try (Connection conn2 = DriverManager.getConnection(connURL);
     PreparedStatement psList =
         conn2.prepareStatement("SELECT * FROM meal_discount ORDER BY id DESC");
     ResultSet rs = psList.executeQuery()) {
%>

<table>
  <tr>
    <th>ID</th><th>Name</th><th>Description</th><th>Type</th>
    <th>Value</th><th>Min Spend</th><th>Start</th><th>End</th>
    <th>Active</th><th>Actions</th>
  </tr>

<%
  while (rs.next()) {
%>
  <tr>
    <td><%= rs.getInt("id") %></td>
    <td><%= rs.getString("name") %></td>
    <td><%= rs.getString("description") %></td>
    <td><%= rs.getString("discount_type") %></td>
    <td><%= rs.getBigDecimal("value") %></td>
    <td><%= rs.getBigDecimal("min_spend") %></td>
    <td><%= rs.getDate("start_date") %></td>
    <td><%= rs.getDate("end_date") %></td>
    <td><%= rs.getInt("is_active") == 1 ? "Yes" : "No" %></td>
    <td>
      <a class="btn btn-edit"
         href="<%=request.getContextPath()%>/admin/editMealDiscount.jsp?action=edit&id=<%=rs.getInt("id")%>">Edit</a>

      <a class="btn btn-del"
         onclick="return confirm('Delete this discount?');"
         href="<%=request.getContextPath()%>/admin/editMealDiscount.jsp?action=delete&id=<%=rs.getInt("id")%>">Delete</a>
    </td>
  </tr>
<%
  }
%>

</table>

<%
} catch (Exception e) {
   out.println("<p style='color:red'>List error: " + e.getMessage() + "</p>");
}
%>

</body>
</html>
