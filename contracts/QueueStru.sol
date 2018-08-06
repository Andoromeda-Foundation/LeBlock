pragma solidity ^0.4.24;

/**
 * @title QueueStru
 * @dev the queue data structure
 */
contract QueueStru {

    struct Queue {
        address[] data;
        uint256 front;
        uint256 back;
    }

    /** 
     * @dev the number of elements stored in the queue.
     */ 
    function length(Queue storage q) 
        view 
        internal 
        returns (uint256) 
    {
        return q.back - q.front;
    }

    /**
     * @dev the number of elements this queue can hold
     */
    function capacity(Queue storage q) 
        view 
        internal 
        returns (uint256) 
    {
        return q.data.length - 1;
    }

    /**
     * @dev the number of element at the front of the queue
     */
    function query(Queue storage q)
        view 
        internal 
        returns (address) 
    {
        if (q.back == q.front) 
            return;
        return q.data[q.front]; 
    }

    /**
     * @dev push a new element to the back of the queue
     */
    function push(Queue storage q, address data) 
        internal
    {
        if ((q.back + 1) % q.data.length == q.front)
            return; // throw;
        q.data[q.back] = data;
        q.back = (q.back + 1) % q.data.length;
    }

    /**
     * @dev remove and return the element at the front of the queue
     */
    function pop(Queue storage q) 
        internal 
    {
        if (q.back == q.front)
            return; // throw;
        delete q.data[q.front];
        q.front = (q.front + 1) % q.data.length;
    }
}