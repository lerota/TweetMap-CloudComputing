
import java.sql.*;

import twitter4j.FilterQuery;
import twitter4j.StallWarning;
import twitter4j.Status;
import twitter4j.StatusDeletionNotice;
import twitter4j.StatusListener;
import twitter4j.TwitterException;
import twitter4j.TwitterStream;
import twitter4j.TwitterStreamFactory;
import twitter4j.conf.ConfigurationBuilder;

public final class TweetGet {

	public static int count = 0;
	public static KeyWordManagement kwmng = new KeyWordManagement();
    public static void main(String[] args) throws TwitterException {
    	 ConfigurationBuilder cb = new ConfigurationBuilder();
         cb.setDebugEnabled(true)
           .setOAuthConsumerKey("************")
           .setOAuthConsumerSecret("**************")
           .setOAuthAccessToken("**************")
           .setOAuthAccessTokenSecret("*****************");
         
         try {
	         final TwitterStream twitterStream = new TwitterStreamFactory(cb.build()).getInstance();
	         final Connection conn = TweetToDB.createConnection();
	         StatusListener listener = new StatusListener() {
	             @Override
	             public void onStatus(Status status) {	            
               	 if (count < 1000) {
	             		if (status.getGeoLocation() != null && status.getLang().equals("en")){
		            		 String text = status.getText();
		            		 String display = new String(text);
		            		 
		            		 String topic = kwmng.getTopic(status);		            		 
		            		 
		            		 if (display.length() > 100) {
		            			 display = display.substring(0, 101);
		            		 }
	             			PreparedStatement preparedStatement = null;
	             			try {
	             				preparedStatement = conn.prepareStatement("insert into TwitterMap2 values(?, ?, ?, ?, ?, ?, ?)");
	             				preparedStatement.setString(1, Long.toString(status.getId()));
								preparedStatement.setString(2, status.getUser().getScreenName() );
								preparedStatement.setString(3, Double.toString(status.getGeoLocation().getLatitude()));
								preparedStatement.setString(4, Double.toString(status.getGeoLocation().getLongitude()));
								preparedStatement.setString(5, status.getText());
								preparedStatement.setString(6, "" + status.getCreatedAt());
								preparedStatement.setString(7, topic);
								preparedStatement.executeUpdate();						
							} catch (SQLException e) {
								e.printStackTrace();
							}
	                      count++;
	             		}
	             	} 
	            	 else{
	             		twitterStream.clearListeners();
	             		twitterStream.shutdown();
	             	}
	             }
	
	             @Override
	             public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {
	             }
	
	             @Override
	             public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
	             }
	
	             @Override
	             public void onScrubGeo(long userId, long upToStatusId) {
	             }
	
	             @Override
	             public void onStallWarning(StallWarning warning) {
	             }
	
	             @Override
	             public void onException(Exception ex) {
	                 ex.printStackTrace();
	             }
	         };
	         twitterStream.addListener(listener);
	         FilterQuery filter = new FilterQuery();
	         KeyWordManagement kw = new KeyWordManagement();
	         String[] keywordsArray = kw.keyWords;
	         filter.track(keywordsArray);
	         twitterStream.filter(filter);
	          
         } catch (Exception e) {
        	 System.out.println(e);
         }
     }
 }