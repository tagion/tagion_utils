module tagion.utils.Queue;

@safe
class Queue(T) {
    private Element _head;
    private Element _tail;
    class Element {
        Element _next;
        Element _previous;
        private T data;
        this(T data) {
            this.data=data;
        }
        ~this() {
            _next=_previous=null;
        }
    }

    void write(T data) {
        auto element=new Element(data);
        if ( _head ) {
            element._next = _head;
            _head._previous = element;
            _head = element;
        }
        else {
            _head = element;
            _tail = element;
        }
    }

    T read()
        in {
            assert(_tail, "Data queue is empty");
        }
    do {
        auto entry=_tail;
        scope(exit) {
            entry._previous=null;
//            entry.destroy;
        }
        immutable result=entry.data;
        if ( _tail is _head ) {
            _tail = _head = null;
        }
        else {
            entry._previous._next=null;
            _tail=entry._previous;
        }
        return result;
    }

    ~this() {
        @safe
        void erase(Element e) {
            if ( e ) {
                erase(e._next);
                e._next=null;
                e._previous=null;
            }
        }
        erase(_head);
        _head=_tail=null;
    }

    void remove(Element entry) {
        if ( entry ) {
            if ( _head is entry ) {
                _head=entry._next;
            }
            if ( _tail is entry ) {
                _tail=entry._previous;
            }
            if ( entry._previous ) {
                entry._previous._next=entry._next;
            }
            if ( entry._next ) {
                entry._next._previous=entry._previous;
            }
        }
    }

    bool empty() nothrow {
        return _head is null;
    }

    Iterator iterator() {
        return Iterator(this);
    }

    struct Iterator {
        private Element entry;
        private Queue owner;
        this(Queue owner) {
            this.owner=owner;
            entry=owner._tail;
        }
        bool empty() pure const nothrow {
            return entry is null;
        }
        void popFront() {
            entry=entry._previous;
        }
        // void popBack() {
        //     entry=entry._previous;
        // }
        T front() {
            return entry.data;
        }

        void remove() {
            owner.remove(entry);
        }
    }

    unittest { // One element
        auto q=new Queue!string;
        assert(q.empty);
        immutable elm1="1";

        q.write(elm1);
        assert(!q.empty);
        assert(q.read == elm1);
        assert(q.empty);
    }

    unittest { // More elements
        immutable elm1="A";
        immutable elm2="B";
        immutable elm3="C";
        auto q=new Queue!string;

        q.write(elm1);
        assert(!q.empty);
        q.write(elm2);
        assert(!q.empty);
        q.write(elm3);
        assert(!q.empty);

        assert(q.read == elm1);
        assert(q.read == elm2);
        assert(q.read == elm3);
        assert(q.empty);
    }

    unittest {
        immutable elm=[
            "A",
            "B",
            "C"
            ];
        { // Iterator
            auto q=new Queue!string;
            foreach(ref e; elm) {
                q.write(e);
            }

            uint i=0;
            foreach(d; q.iterator) {
                assert(elm[i] == d);
                i++;
            }
        }
        {  // Remove first
            auto q=new Queue!string;
            foreach(ref e; elm) {
                q.write(e);
            }

            auto iter=q.iterator;

            iter.remove;
            assert(q.read == elm[1]);
            assert(q.read == elm[2]);
        }
        {  // Remove middel
            auto q=new Queue!string;
            foreach(ref e; elm) {
                q.write(e);
            }

            auto iter=q.iterator;
            iter.popFront;
            iter.remove;
            assert(q.read == elm[0]);
            assert(q.read == elm[2]);
        }
        {  // Remove last
            auto q=new Queue!string;
            foreach(ref e; elm) {
                q.write(e);
            }

            auto iter=q.iterator;
            iter.popFront;
            iter.popFront;
            iter.remove;
            assert(q.read == elm[0]);
            assert(q.read == elm[1]);
        }
    }

}