<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.math.BigDecimal" %>

<!-- ===== AUTH CHECK (ADMIN ONLY) ===== -->
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/AuthCheckAdmin.jsp" />
<%! 
    public BigDecimal parseDecimal(String s, BigDecimal def) {
        try {
            if (s == null || s.trim().isEmpty()) return def;
            return new BigDecimal(s.trim());
        } catch (Exception e) { 
            return def; 
        }
    }

    public Timestamp parseTimestamp(String s) {
        try {
            if (s == null || s.trim().isEmpty()) return null;
            String fixed = s.replace("T", " ") + ":00";
            return Timestamp.valueOf(fixed);
        } catch (Exception e) { 
            return null; 
        }
    }
%>

<%
String connURL =
"jdbc:mysql://localhost:3306/jad_assign1"
+ "?user=root"
+ "&password=1G9r5a6c1E**"
+ "&serverTimezone=UTC"
+ "&useSSL=false"
+ "&allowPublicKeyRetrieval=true";

Class.forName("com.mysql.cj.jdbc.Driver");

String action = request.getParameter("action");
if (action == null) action = "";

// FORM STATE VARIABLES
String formId = "";
String formName = "";
String formType = "PERCENT";
String formAmount = "0";
String formMinOrder = "";
String formStart = "";
String formEnd = "";
String formStackable = "0";
String formActive = "1";

Connection conn = null;

try {
    conn = DriverManager.getConnection(connURL);

    // DELETE RULE
    if ("delete".equals(action)) {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            PreparedStatement psDel =
                conn.prepareStatement("DELETE FROM grocery_discount_rule WHERE id = ?");
            psDel.setInt(1, Integer.parseInt(idStr));
            psDel.executeUpdate();
            psDel.close();
        }
        response.sendRedirect(request.getContextPath() + "/admin/editGroceryDiscount.jsp");
        return;
    }

    // INSERT / UPDATE RULE
    if ("save".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {

        String idStr = request.getParameter("id");
        String name = request.getParameter("name");
        String type = request.getParameter("type");
        BigDecimal amount = parseDecimal(request.getParameter("amount"), BigDecimal.ZERO);
        BigDecimal minOrder = parseDecimal(request.getParameter("min_order_amount"), null);
        Timestamp startTs = parseTimestamp(request.getParameter("start_date"));
        Timestamp endTs = parseTimestamp(request.getParameter("end_date"));
        int isStackable = "1".equals(request.getParameter("is_stackable")) ? 1 : 0;
        int isActive = "1".equals(request.getParameter("is_active")) ? 1 : 0;

        if (idStr == null || idStr.trim().isEmpty()) {
            String insertSql = "INSERT INTO grocery_discount_rule " +
                    "(name, type, amount, min_order_amount, start_date, end_date, is_stackable, is_active) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement psIns = conn.prepareStatement(insertSql);
            psIns.setString(1, name);
            psIns.setString(2, type);
            psIns.setBigDecimal(3, amount);
            if (minOrder == null) psIns.setNull(4, Types.DECIMAL);
            else psIns.setBigDecimal(4, minOrder);
            if (startTs == null) psIns.setNull(5, Types.TIMESTAMP);
            else psIns.setTimestamp(5, startTs);
            if (endTs == null) psIns.setNull(6, Types.TIMESTAMP);
            else psIns.setTimestamp(6, endTs);
            psIns.setInt(7, isStackable);
            psIns.setInt(8, isActive);

            psIns.executeUpdate();
            psIns.close();

        } else {
            String updateSql = "UPDATE grocery_discount_rule SET " +
                    "name=?, type=?, amount=?, min_order_amount=?, start_date=?, end_date=?, is_stackable=?, is_active=? " +
                    "WHERE id=?";

            PreparedStatement psUpd = conn.prepareStatement(updateSql);
            psUpd.setString(1, name);
            psUpd.setString(2, type);
            psUpd.setBigDecimal(3, amount);
            if (minOrder == null) psUpd.setNull(4, Types.DECIMAL);
            else psUpd.setBigDecimal(4, minOrder);
            if (startTs == null) psUpd.setNull(5, Types.TIMESTAMP);
            else psUpd.setTimestamp(5, startTs);
            if (endTs == null) psUpd.setNull(6, Types.TIMESTAMP);
            else psUpd.setTimestamp(6, endTs);
            psUpd.setInt(7, isStackable);
            psUpd.setInt(8, isActive);
            psUpd.setInt(9, Integer.parseInt(idStr));

            psUpd.executeUpdate();
            psUpd.close();
        }

        response.sendRedirect(request.getContextPath() + "/admin/editGroceryDiscount.jsp");
        return;
    }

    // LOAD RULE FOR EDITING
    if ("edit".equals(action)) {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            PreparedStatement psOne =
                conn.prepareStatement("SELECT * FROM grocery_discount_rule WHERE id=?");
            psOne.setInt(1, Integer.parseInt(idStr));
            ResultSet r1 = psOne.executeQuery();

            if (r1.next()) {
                formId = r1.getString("id");
                formName = r1.getString("name");
                formType = r1.getString("type");
                formAmount = r1.getBigDecimal("amount").toString();

                BigDecimal mo = r1.getBigDecimal("min_order_amount");
                formMinOrder = (mo == null) ? "" : mo.toString();

                Timestamp sd = r1.getTimestamp("start_date");
                Timestamp ed = r1.getTimestamp("end_date");

                if (sd != null) formStart = sd.toString().substring(0,16).replace(" ", "T");
                if (ed != null) formEnd = ed.toString().substring(0,16).replace(" ", "T");

                formStackable = r1.getInt("is_stackable") + "";
                formActive = r1.getInt("is_active") + "";
            }
            r1.close();
            psOne.close();
        }
    }

} catch (Exception e) {
    out.println("<p class='text-red-600 font-semibold'>Error: " + e.getMessage() + "</p>");
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Edit Grocery Discounts</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100 min-h-screen p-6">

<h1 class="text-3xl font-bold text-gray-800 mb-6">Grocery Discount Rules</h1>

<a href="<%=request.getContextPath()%>/admin/admin_homePage.jsp"
   class="inline-block mb-6 text-sm font-medium text-gray-700 hover:text-indigo-600">
    ← Back to Admin Home
</a>

<!-- ========= FORM CARD ========= -->
<div class="bg-white shadow-md rounded-xl p-6 mb-10 max-w-2xl">

  <h2 class="text-xl font-semibold mb-4">
    <%= (formId.isEmpty() ? "Create New Rule" : "Edit Rule #" + formId) %>
  </h2>

  <form method="post"
        action="<%=request.getContextPath()%>/admin/editGroceryDiscount.jsp?action=save"
        class="space-y-4">

    <input type="hidden" name="id" value="<%=formId%>" />

    <!-- NAME -->
    <div>
      <label class="font-medium">Rule Name</label>
      <input type="text" name="name" required
             value="<%=formName%>"
             class="w-full mt-1 p-2 border rounded-lg focus:ring focus:ring-indigo-300" />
    </div>

    <!-- TYPE -->
    <div>
      <label class="font-medium">Type</label>
      <select name="type"
              class="w-full mt-1 p-2 border rounded-lg">
        <option value="PERCENT"  <%= "PERCENT".equals(formType) ? "selected" : "" %>>PERCENT</option>
        <option value="FLAT"     <%= "FLAT".equals(formType) ? "selected" : "" %>>FLAT</option>
        <option value="SHIPPING" <%= "SHIPPING".equals(formType) ? "selected" : "" %>>SHIPPING</option>
      </select>
    </div>

    <!-- AMOUNT -->
    <div>
      <label class="font-medium">Amount</label>
      <input type="number" step="0.1" name="amount" value="<%=formAmount%>"
             class="w-full mt-1 p-2 border rounded-lg" />
      <p class="text-xs text-gray-500 mt-1">
        (10 = 10% for PERCENT or $10 for FLAT)
      </p>
    </div>

    <!-- MIN ORDER -->
    <div>
      <label class="font-medium">Minimum Order Amount</label>
      <input type="number" step="0.01" name="min_order_amount" value="<%=formMinOrder%>"
             class="w-full mt-1 p-2 border rounded-lg" />
    </div>

    <!-- DATE FIELDS -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div>
        <label class="font-medium">Start Date</label>
        <input type="datetime-local" name="start_date" value="<%=formStart%>"
               class="w-full mt-1 p-2 border rounded-lg" />
      </div>

      <div>
        <label class="font-medium">End Date</label>
        <input type="datetime-local" name="end_date" value="<%=formEnd%>"
               class="w-full mt-1 p-2 border rounded-lg" />
      </div>
    </div>

    <!-- OPTIONS -->
    <div class="flex items-center gap-3">
      <input type="checkbox" name="is_stackable" value="1"
             <%= "1".equals(formStackable) ? "checked" : "" %> />
      <label class="font-medium">Stackable</label>
    </div>

    <div class="flex items-center gap-3">
      <input type="checkbox" name="is_active" value="1"
             <%= "1".equals(formActive) ? "checked" : "" %> />
      <label class="font-medium">Active</label>
    </div>

    <button type="submit"
            class="bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700">
      Save Rule
    </button>

    <a href="<%=request.getContextPath()%>/admin/editGroceryDiscount.jsp"
       class="ml-3 bg-gray-300 text-gray-800 px-4 py-2 rounded-lg hover:bg-gray-400">
      Clear Form
    </a>
  </form>
</div>


<!-- ===== TABLE LIST ===== -->
<%
try {
    PreparedStatement psList =
        conn.prepareStatement("SELECT * FROM grocery_discount_rule ORDER BY id DESC");
    ResultSet rs = psList.executeQuery();
%>

<div class="bg-white shadow-md rounded-xl p-6">
  <h2 class="text-xl font-semibold mb-4">Existing Rules</h2>

  <table class="w-full text-left border rounded-lg overflow-hidden">
    <thead class="bg-gray-200">
      <tr>
        <th class="p-3">ID</th>
        <th class="p-3">Name</th>
        <th class="p-3">Type</th>
        <th class="p-3">Amount</th>
        <th class="p-3">Min Order</th>
        <th class="p-3">Start</th>
        <th class="p-3">End</th>
        <th class="p-3">Stackable</th>
        <th class="p-3">Active</th>
        <th class="p-3">Actions</th>
      </tr>
    </thead>

    <tbody>
<%
  while (rs.next()) {
%>
      <tr class="border-b hover:bg-gray-50">
        <td class="p-3"><%= rs.getInt("id") %></td>
        <td class="p-3"><%= rs.getString("name") %></td>
        <td class="p-3"><%= rs.getString("type") %></td>
        <td class="p-3"><%= rs.getBigDecimal("amount") %></td>
        <td class="p-3"><%= rs.getBigDecimal("min_order_amount") %></td>
        <td class="p-3"><%= rs.getTimestamp("start_date") %></td>
        <td class="p-3"><%= rs.getTimestamp("end_date") %></td>
        <td class="p-3"><%= rs.getInt("is_stackable") == 1 ? "Yes" : "No" %></td>
        <td class="p-3"><%= rs.getInt("is_active") == 1 ? "Yes" : "No" %></td>
        <td class="p-3">
          <a href="<%=request.getContextPath()%>/admin/editGroceryDiscount.jsp?action=edit&id=<%=rs.getInt("id")%>"
             class="text-indigo-600 hover:underline mr-3">Edit</a>

          <a onclick="return confirm('Delete this rule?');"
             href="<%=request.getContextPath()%>/admin/editGroceryDiscount.jsp?action=delete&id=<%=rs.getInt("id")%>"
             class="text-red-600 hover:underline">Delete</a>
        </td>
      </tr>
<%
  }
  rs.close();
  psList.close();
} catch (Exception e) {
   out.println("<p class='text-red-600'>" + e.getMessage() + "</p>");
} finally {
   if (conn != null) conn.close();
}
%>
    </tbody>
  </table>
</div>

</body>
</html>
