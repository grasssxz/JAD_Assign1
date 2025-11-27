<%@ page import="java.sql.*" %>
<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />

<%
    int itemId = Integer.parseInt(request.getParameter("item_id"));
    int quantity = Integer.parseInt(request.getParameter("quantity"));

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
    );

    PreparedStatement ps = conn.prepareStatement(
        "UPDATE cart_item SET quantity=? WHERE id=?"
    );
    ps.setInt(1, quantity);
    ps.setInt(2, itemId);
    ps.executeUpdate();

    conn.close();
%>

<script>
alert("Quantity updated!");
window.location.href = "ViewCart.jsp";
</script>
