import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier

import javax.annotation.PostConstruct
import javax.sql.DataSource
import java.sql.DatabaseMetaData

/**
 * Helper service to make it easier to write code that works on both Oracle and
 * PostgreSQL. Of course, the best option in this respect is to use Hibernate.
 */
class DatabasePortabilityService {

    @Autowired
    @Qualifier("dataSource")
    DataSource dataSource

    DatabaseType databaseType;

    enum DatabaseType {
        POSTGRESQL,
        ORACLE
    }

    private runCorrectImplementation(Closure postgresImpl, Closure oracleImpl) {
        switch (databaseType) {
            case DatabaseType.POSTGRESQL:
                return postgresImpl()
            case DatabaseType.ORACLE:
                return oracleImpl()
            default:
                throw new IllegalStateException("Should not reach this point")
        }
    }

    String createTopNQuery(String s) {
        runCorrectImplementation(
                { "$s LIMIT ?" },
                { "SELECT * FROM ($s) WHERE ROWNUM <= ?" }
        )
    }

    /**
     * Create pagination query.
     * It is important that the query is doing a sort by something unique!
     * That is, there should not be rows comparing equal.
     *
     * @param s the string to transform
     * @param rowNumberColName the name of the column with the row index,
     *                         or null for none
     * @return the transformed query
     */
    String createPaginationQuery(String s, String rowNumberColName=null) {
        runCorrectImplementation(
                /* PostgreSQL */
                {
                    if (rowNumberColName == null) {
                        "$s LIMIT ? OFFSET ?"
                    } else {
                        """
                        SELECT
                            row_number() OVER () AS $rowNumberColName, *
                        FROM ( $s ) pag_a
                        LIMIT ?
                        OFFSET ?
                        """
                    }
                },
                /* Oracle */
                {
                    String rowColumnFragment = ""
                    if (rowNumberColName != null) {
                        rowColumnFragment = ", rnum AS $rowNumberColName"
                    }

                    /* see http://www.oracle.com/technetwork/issue-archive/2006/06-sep/o56asktom-086197.html */
                    """
                    SELECT
                        *$rowColumnFragment
                    FROM (
                            SELECT
                                /*+ FIRST_ROWS(n) */
                                pag_a.*,
                                ROWNUM rnum
                            FROM ( $s ) pag_a
                            WHERE
                                ROWNUM <= ? /* last row to include */ )
                    WHERE
                        rnum >= ? /* first row to include */"""
                }
        )
    }

    /* Convert limit into Oracle's first row number to exclude, if applicable */
    List convertLimitStyle(Number limit, Number offset) {
        runCorrectImplementation(
                { [limit, offset] }, /* do not convert for PostgreSQL */
                { [offset + limit, offset + 1] }
        )
    }

    /**
     * Convert pagination limits for use with queries transformed with the
     * methods available in this class.
     *
     * @param start starting index, 1-based, inclusive
     * @param end ending index, 1-based, inclusive
     * @return list with two elements in the order they should be in order to
     * replace the placeholders in the queries generated by this class methods
     */
    List convertRangeStyle(Number start /* incl, 1-based */, Number end /* incl */) {
        runCorrectImplementation(
                { [end - start + 1, start - 1] },
                { [end, start] } /* do not convert for Oracle */
        )
    }

    @PostConstruct
    void init() {
        DatabaseMetaData metaData = dataSource.connection.metaData
        def databaseName = metaData.databaseProductName.toLowerCase()

        switch (databaseName) {
        case ~/postgresql.*/:
            databaseType = DatabaseType.POSTGRESQL
            break

        case ~/oracle.*/:
            databaseType = DatabaseType.ORACLE
            break

        default:
            log.warn 'Could not detect data source driver as either ' +
                    'PostgreSQL or Oracle; defaulting to PostgreSQL ' +
                    '(this is OK if running H2 in Postgres compatibility ' +
                    'mode)'
            databaseType = DatabaseType.POSTGRESQL
        }
    }


}
