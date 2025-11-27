<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<jsp:include page="/auth/AuthCheckAdmin.jsp" />

<%
/* ===============================
   1. CONNECTION
================================*/
Class.forName("com.mysql.cj.jdbc.Driver");
String connURL =
"jdbc:mysql://localhost:3306/jad_assign1"
+ "?user=root"
+ "&password=1G9r5a6c1E**"
+ "&serverTimezone=UTC"
+ "&useSSL=false"
+ "&allowPublicKeyRetrieval=true";

Connection conn = DriverManager.getConnection(connURL);
if (conn == null) {
    out.println("<p style='color:red'>Connection still NULL</p>");
} else {
    out.println("<p style='color:green'>Connection OK</p>");
}


String ctx = request.getContextPath();

/* ===============================
   2. HANDLE FORM ACTIONS
================================*/

// ADD CATEGORY
if ("add".equals(request.getParameter("action"))) {
    String name = request.getParameter("category_name");
    String pic  = request.getParameter("category_picture");

    PreparedStatement psAdd = conn.prepareStatement(
        "INSERT INTO category (category_name, category_picture) VALUES (?, ?)"
    );
    psAdd.setString(1, name);
    psAdd.setString(2, pic);
    psAdd.executeUpdate();
    psAdd.close();
}

// UPDATE CATEGORY
if ("update".equals(request.getParameter("action"))) {
    int id = Integer.parseInt(request.getParameter("id"));
    String name = request.getParameter("category_name");
    String pic  = request.getParameter("category_picture");

    PreparedStatement psUpdate = conn.prepareStatement(
        "UPDATE category SET category_name=?, category_picture=? WHERE id=?"
    );
    psUpdate.setString(1, name);
    psUpdate.setString(2, pic);
    psUpdate.setInt(3, id);
    psUpdate.executeUpdate();
    psUpdate.close();
}

// DELETE CATEGORY
if ("delete".equals(request.getParameter("action"))) {
    int id = Integer.parseInt(request.getParameter("id"));

    PreparedStatement psDelete = conn.prepareStatement(
        "DELETE FROM category WHERE id=?"
    );
    psDelete.setInt(1, id);
    psDelete.executeUpdate();
    psDelete.close();
}

/* ===============================
   3. QUERY TO GET ALL CATEGORIES
================================*/
PreparedStatement psList = conn.prepareStatement(
    "SELECT id, category_name, category_picture FROM category ORDER BY id ASC"
);
ResultSet rsList = psList.executeQuery();

%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Edit Categories</title>

<style>
body { font-family: Arial; padding: 20px; }

table {
  width: 90%;
  border-collapse: collapse;
  margin-top: 20px;
}

th, td {
  border: 1px solid #ddd;
  padding: 10px;
  text-align: left;
}

th { background: #f0f0ff; }

.add-form, .edit-form {
  margin-bottom: 30px;
  padding: 20px;
  background: #fafafa;
  border: 1px solid #ddd;
  border-radius: 10px;
  width: 420px;
}

input[type=text] {
  width: 95%;
  padding: 8px;
  margin: 5px 0;
}

button {
  background: #7f9cf5;
  color: white;
  border: none;
  padding: 8px 14px;
  margin-top: 8px;
  border-radius: 6px;
  cursor: pointer;
}
button:hover {
  background: #5e7ce0;
}
.delete-btn {
  background: #e15858;
}
.delete-btn:hover {
  background: #c14141;
}
</style>

</head>
<body>

<h1>🛠 Manage Categories</h1>

<a href="<%= ctx %>/admin/admin_homePage.jsp">← Back to Admin Home</a>

<!-- ADD CATEGORY -->
<div class="add-form">
  <h3>Add New Category</h3>
  <form method="post" action="editCategories.jsp">
    <input type="hidden" name="action" value="add">

    <label>Category Name:</label><br>
    <input type="text" name="category_name" required><br>

    <label>Picture Filename (e.g. cleaning.png):</label><br>
    <input type="text" name="category_picture"><br>

    <button type="submit">Add Category</button>
  </form>
</div>

<!-- LIST + EDIT EXISTING CATEGORIES -->
<h2>Existing Categories</h2>

<!-- back to home page button -->
<a class="btn" 
   style="background:#64748b; color:white;"
   href="<%=request.getContextPath()%>/admin/admin_homePage.jsp">
    ← Back to Admin Home
</a>

<table>
<tr>
  <th>ID</th>
  <th>Name</th>
  <th>Picture</th>
  <th>Edit</th>
  <th>Delete</th>
</tr>

<%
while (rsList.next()) {
    int id   = rsList.getInt("id");
    String nm  = rsList.getString("category_name");
    String pic = rsList.getString("category_picture");
%>

<tr>
  <td><%= id %></td>

  <!-- EDIT FORM FOR EACH ROW -->
  <td>
    <form method="post" action="editCategories.jsp">
      <input type="hidden" name="action" value="update">
      <input type="hidden" name="id" value="<%= id %>">

      <input type="text" name="category_name" value="<%= nm %>" required>
  </td>

  <td>
      <input type="text" name="category_picture" value="<%= pic %>">
  </td>

  <td>
      <button type="submit">Save</button>
    </form>
  </td>

  <td>
    <form method="post" action="editCategories.jsp" onsubmit="return confirm('Delete this category?');">
      <input type="hidden" name="action" value="delete">
      <input type="hidden" name="id" value="<%= id %>">
      <button class="delete-btn">Delete</button>
    </form>
  </td>
</tr>

<% } %>

</table>

<%
rsList.close();
psList.close();
conn.close();
%>

</body>
</html>
