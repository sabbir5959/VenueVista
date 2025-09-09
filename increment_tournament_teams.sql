-- Function to increment registered teams count for a tournament
CREATE OR REPLACE FUNCTION increment_tournament_teams(tournament_id uuid)
RETURNS void AS $$
BEGIN
    UPDATE tournaments 
    SET registered_teams = COALESCE(registered_teams, 0) + 1
    WHERE id = tournament_id;
END;
$$ LANGUAGE plpgsql;
