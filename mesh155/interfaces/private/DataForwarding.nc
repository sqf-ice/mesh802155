/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

interface DataForwarding {
	command uint16_t nextHop(uint16_t dst, uint8_t * up_down_flag, uint8_t criteria);
}
