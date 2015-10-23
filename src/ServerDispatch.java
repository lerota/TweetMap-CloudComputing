
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import org.json.JSONException;
import org.json.JSONObject;

@ServerEndpoint(value = "/aws")

public class ServerDispatch {

	static String dbName = "twitterMap1";
	static String userName = "*********";
	static String password = "*********";
	static String hostname = "*********";
	static String port = "3306";
	static String jdbcUrl = "jdbc:mysql://" + hostname + ":" +
					port + "/" + dbName + "?user=" + userName + "&password=" + password;
	Connection conn = null;
	static Statement setupStatement = null;
	static ResultSet resultSet = null;
	static ResultSet resultSetTF = null;
	static ResultSet resultSetTS = null;
	static ResultSet resultSetTT = null;
	static ResultSet resultSetTE = null;

	
	String keyword = null;
	
    private static final Logger LOGGER = 
            Logger.getLogger(ServerDispatch.class.getName());
    
    @OnOpen
    public void onOpen(Session session) throws IOException {
      	conn = DBcontrol.getConn(jdbcUrl);
        LOGGER.log(Level.INFO, "New connection with client: {0}", 
                session.getId());
    }
    
    @OnMessage
    public void onMessage(String message, Session session) throws IOException, InterruptedException {
    	keyword = message;
    	JSONObject locOBJ = new JSONObject();
    	int count = 1;
    	String selectSQL = null;
    	String selectSQLF = null;
    	String selectSQLT = null;
    	String selectSQLE = null;
    	String selectSQLS = null;
		for (Session peer : session.getOpenSessions()) {
                try {
        			if (keyword.equals("all")){
        				selectSQL = "SELECT * FROM TwitterMap2;";
          				selectSQLF = "SELECT COUNT(*) FROM TwitterMap2 t1 WHERE t1.Topic = 'finance';";
        				selectSQLT = "SELECT COUNT(*) FROM TwitterMap2 t1 WHERE t1.Topic = 'technology';";
        				selectSQLE = "SELECT COUNT(*) FROM TwitterMap2 t1 WHERE t1.Topic = 'entertainment';";
        				selectSQLS = "SELECT COUNT(*) FROM TwitterMap2 t1 WHERE t1.Topic = 'sports';";
        			} else if (keyword.equals("apple") || keyword.equals("football") || keyword.equals("Taylor Swift") || keyword.equals("Accenture")) {
        				selectSQL = "SELECT * FROM TwitterMap2 t1 "
        						+ "WHERE t1.Text LIKE " + "'%" + keyword + "%';";
        				selectSQLF = "SELECT COUNT(*) FROM TwitterMap2 t1 WHERE t1.Topic = 'finance';";
        				selectSQLT = "SELECT COUNT(*) FROM TwitterMap2 t1 WHERE t1.Topic = 'technology';";
        				selectSQLE = "SELECT COUNT(*) FROM TwitterMap2 t1 WHERE t1.Topic = 'entertainment';";
        				selectSQLS = "SELECT COUNT(*) FROM TwitterMap2 t1 WHERE t1.Topic = 'sports';";
        			} else if(keyword.equals("finance") || keyword.equals("technology") || keyword.equals("entertainment") || keyword.equals("sports")){			
        				selectSQL = "SELECT * FROM TwitterMap2 t1 "
        						+ " WHERE t1.Topic = '" + keyword + "';";
        				selectSQLF = "SELECT COUNT(*) FROM TwitterMap2 t1 WHERE t1.Topic = 'finance';";
        				selectSQLT = "SELECT COUNT(*) FROM TwitterMap2 t1 WHERE t1.Topic = 'technology';";
        				selectSQLE = "SELECT COUNT(*) FROM TwitterMap2 t1 WHERE t1.Topic = 'entertainment';";
        				selectSQLS = "SELECT COUNT(*) FROM TwitterMap2 t1 WHERE t1.Topic = 'sports';";
        			} else {
        				selectSQL = "SELECT * FROM TwitterMap2;";
        				selectSQLF = "SELECT COUNT(*) FROM TwitterMap2 t1 WHERE t1.Topic = 'finance';";
        				selectSQLT = "SELECT COUNT(*) FROM TwitterMap2 t1 WHERE t1.Topic = 'technology';";
        				selectSQLE = "SELECT COUNT(*) FROM TwitterMap2 t1 WHERE t1.Topic = 'entertainment';";
        				selectSQLS = "SELECT COUNT(*) FROM TwitterMap2 t1 WHERE t1.Topic = 'sports';";		
        			}
        			System.out.println(selectSQL);
        			resultSet = DBcontrol.doSelect(conn, selectSQL, setupStatement, resultSet);
        			resultSetTF = DBcontrol.doSelect(conn, selectSQLF, setupStatement, resultSetTF);
        			resultSetTE = DBcontrol.doSelect(conn, selectSQLE, setupStatement, resultSetTE);
        			resultSetTS = DBcontrol.doSelect(conn, selectSQLS, setupStatement, resultSetTS);
        			resultSetTT = DBcontrol.doSelect(conn, selectSQLT, setupStatement, resultSetTT);
        			resultSetTF.next();
        			int numF = resultSetTF.getInt(1);
        			resultSetTE.next();
    				int numE = resultSetTE.getInt(1);
        			resultSetTS.next();
    				int numS = resultSetTS.getInt(1);
        			resultSetTT.next();
    				int numT = resultSetTT.getInt(1);

        			while(resultSet.next()){
        				String lng = resultSet.getString("Longitude");
        				String lat = resultSet.getString("Latitude");       				
			
        				JSONObject loc = new JSONObject();
        				loc.put("longitude", lng);
        				loc.put("latitude", lat);
        				loc.put("finance", numF);
        				loc.put("entertainment", numE);
        				loc.put("technology", numT);
        				loc.put("sports", numS);

        				locOBJ.put("loc"+count, loc);
        				count++;
        			}
        		}catch (SQLException | JSONException e) {
        			e.printStackTrace();
        		}
                peer.getBasicRemote().sendText(locOBJ.toString());
                Thread.sleep(2000);
		}
    }
    
    @OnClose
    public void onClose(Session session) {
    	DBcontrol.disConn(conn, setupStatement, resultSet);
        LOGGER.log(Level.INFO, "Close connection for client: {0}", 
                session.getId());
    }
    
    @OnError
    public void onError(Throwable exception, Session session) {
        LOGGER.log(Level.INFO, "Error for client: {0}", session.getId());
    }

}