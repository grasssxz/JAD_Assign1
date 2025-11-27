<%@ page import="java.sql.*" %>

<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />

<%
    request.setCharacterEncoding("UTF-8");

    Integer memberId = (Integer) session.getAttribute("member_id");
    String role      = (String) session.getAttribute("type");  

    if (memberId == null) {
%>
        <script>
            alert("Please log in.");
            window.location.href = "../../login/login.html";
        </script>
<%
        return;
    }

    String itemParam = request.getParameter("item_id");
    if (itemParam == null) {
%>
        <script>
            alert("Item ID missing.");
            window.location.href = "ViewCart.jsp";
        </script>
<%
        return;
    }

    int itemId = Integer.parseInt(itemParam);

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
    );

    PreparedStatement ps;

    if ("admin".equalsIgnoreCase(role)) {
        ps = conn.prepareStatement("DELETE FROM cart_item WHERE id=?");
        ps.setInt(1, itemId);

    } else {
        ps = conn.prepareStatement(
            "DELETE ci FROM cart_item ci " +
            "JOIN cart c ON ci.cart_id = c.id " +
            "WHERE ci.id=? AND c.member_id=?"
        );
        ps.setInt(1, itemId);
        ps.setInt(2, memberId);
    }


    int rows = ps.executeUpdate();
    conn.close();
%>

<script>
<% if (rows > 0) { %>
    alert("Item removed from cart.");
<% } else { %>
    alert("Delete failed — item does not belong to you.");
<% } %>
    window.location.href = "ViewCart.jsp";
</script>
